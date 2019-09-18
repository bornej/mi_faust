// Model: Ceramic Clave
// Description: From a clave, to a ceramic bowl.
// Parameters:
//  - Stiffness -> ND-tone:spectra
//  - Damping -> ND-tone:decay
//  - Internal Damping -> ND-tone:bend
//  - Mass -> ND-tone:pitch
//  - Gain -> ND-tone:volume

import("stdfaust.lib");
import("mi.lib");
import("./utils.lib");
declare options "[midi:on]";

listeningVoice = 2;

cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 26, 0, 127, 1);
voice_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedVoice = 1,2,3,4,5,6 :  voice_selector(cc70) :hbargraph("focusedVoice",1,6);

// Our model will listen to incomming CC message only if focus == 1
focus = (listeningVoice == focusedVoice);

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

// Parameters controls

// stiffness
K_preset = 113;
// Damping
Z_preset = 39;
// Mass inertia
M_preset = 42;
// Gain
G_preset = 26;

// Stiffness
K_min = 0.0001;
K_max = 1;
kx = hslider("stiffness [midi:ctrl 30] [hidden:1]", K_preset, 0, 127, 1);
m_K = (kx,focus : holdOrJoin) : ccToVal(K_min, K_max) : hbargraph("Stiffness",K_min,K_max);

// Damping
Z_min = 0.0001;
Z_max = 0.01;
zx = hslider("damping [midi:ctrl 50] [hidden:1]", Z_preset, 0, 127, 1);
m_Z = (zx,focus : holdOrJoin)  : ccToVal(Z_min, Z_max) : hbargraph("Damping",Z_min,Z_max);

// Mass
M_min = 1;
M_max = 10;
mx = hslider("mass[hidden:1][midi:ctrl 31]", M_preset, 0, 127, 1);
m_M = (mx,focus : holdOrJoin) : ccToVal(M_min, M_max) : hbargraph("Mass",M_min,M_max);

// Gain
G_min = 0;
G_max = 0.7;
gx = hslider("gain [midi:ctrl 19]", G_preset, 0, 127, 1); 
OutGain = (gx,focus : holdOrJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",0,0.7);

// Input force value: assigned to ND-tone-BEND (TODO)
gateT =nentry("gate[midi:key %listeningVoice] [hidden:1]",0,0,127,1):ba.impulsify; // ND midi note 60
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

process = in1: model : *(OutGain) <: co.limiter_1176_R4_stereo;
