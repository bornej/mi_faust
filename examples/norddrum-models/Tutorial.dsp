// In this example we explain in details our implementation of
// mi_faust models controlled by the clavia Nord Drum 3P

import("stdfaust.lib");
import("mi.lib");
import("./utils.lib");
declare options "[midi:on]";

// --------------
// * Terminology:
// - Model: The physical model used for sound synthesis in this faust program.
// - Parameters: Our physical model has three parameters
//     M:mass, K:Damper: Z:stiffness.
// - ND: Nord Drum
// - Voices: The ND has six voices (one voice per pad).
//     Our goal is to assign one Faust Model per voice.
//     Each model will be launched in a separate Faust program.
//     Rem: models can be seen as 'small' percusive instruments,
//     sound synthesis engines,
//     with different topology, parameter values, ...
// - Focused voice: On the ND, the voice we are currently editing.
// - Listening voice: The model will receive midi control values from this voice.

// -------------
// * Sidenotes on the ND Midi control change Implementation:
// 
// Idealy we would want
// All the voice-1 Control Changes on ch 1
// All the voice-2 CC on ch 2
//  ...
// All the voice-6 CC on ch 6
//
// Unfortunatelly, the nord drum sends all CC values to a single Channel.
// So we can't use midi channels to filter out CC informations
// comming from the different ND voices.
//
// Let's say we expect our model to receive values from ND voice 1

listeningVoice = 1;

// No other voice than the ND voice 1 has the right to control
// our model parameters.
// Now we need a way to know which ND voice has the focus.

// -----------------
// * Checking focus 
//
// Implementation:
// We listen to CC70 (select voice) values to know which voice is currently focused.
// |-----------+---------------|
// | CC 70 val | focused voice |
// |-----------+---------------|
// |         0 |             1 |
// |        26 |             2 |
// |        51 |             3 |
// |        77 |             4 |
// |       102 |             5 |
// |       127 |             6 |
// |-----------+---------------|

// /!\ TODO: Need to check which voice has focus on startup
// for the moment we need to touch the "ch-select" buttons to trigger a cc70.

cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 26, 0, 127, 1);
voice_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedVoice = 1,2,3,4,5,6 :  voice_selector(cc70) :hbargraph("focusedVoice",1,6);

focus = (listeningVoice == focusedVoice);

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

// ----------------
// * Parameters controls
//
// ** Stiffness parameter: assigned to ND-tone-SPECTRA
K_min = 0.0001;
K_max = 1;
kx = hslider("stiffness [midi:ctrl 30] [hidden:1]", 0, 0, 127, 1);
m_K = (kx,focus : holdAndJoin) : ccToVal(K_min, K_max) : hbargraph("Stiffness",K_min,K_max);

// ** Damping parameter: assigned to ND-tone-DECAY
Z_min = 0.0001;
Z_max = 0.01;
zx = hslider("damping [midi:ctrl 50] [hidden:1]", 0, 0, 127, 1);
m_Z = (zx,focus : holdAndJoin)  : ccToVal(Z_min, Z_max) : hbargraph("Damping",Z_min,Z_max);

// ** Mass parameter: assigned to ND-tone-PITCH
M_min = 1;
M_max = 10;
mx = hslider("mass[hidden:1][midi:ctrl 31]", 0, 0, 127, 1);
m_M = (mx,focus : holdAndJoin) : ccToVal(M_min, M_max) : hbargraph("Mass",M_min,M_max);

// ** Gain parameter: assigned to ND-tone-VOLUME
G_min = 0;
G_max = 0.7;
gx = hslider("gain [midi:ctrl 19]", 127, 0, 127, 1); 
OutGain = (gx,focus : holdAndJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",0,0.7);

// Input force value: assigned to ND-tone-BEND (TODO)
gateT =nentry("gate[midi:key %listeningVoice] [hidden:1]",0,1,127,1):ba.impulsify; // ND midi note 60
in1 = gateT * 0.01;

model = (RoutingLinkToMass: 
ground(0.),
mass(m_M, 0., 0.),
mass(m_M, 0., 0.),
mass(m_M, 0., 0.) :
RoutingMassToLink : 
spring(0.05,0.01, 0., 0.),
spring(m_K,m_Z, 0., 0.),
spring(m_K,m_Z, 0., 0.),
spring(m_K,m_Z, 0., 0.),         par(i, 1,_)
)~par(i, 8, _):         par(i, 8,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2, f_in1) = l0_f1, l0_f2+l1_f1+l3_f2, f_in1+l1_f2+l2_f1, l2_f2+l3_f1;
RoutingMassToLink(m0,m1,m2,m3) = m0, m1, m1, m2, m2, m3, m3, m1,m3;
};

// ---------------
// * Process
// Finding correct parameters range can be hard.
// When doing fine tuning on the model it can be helpfull to add a limiter
// and a bandpass/lowpass/highpass filter to avoid clipping.

process = in1: model : *(OutGain) <: co.limiter_1176_R4_stereo;
