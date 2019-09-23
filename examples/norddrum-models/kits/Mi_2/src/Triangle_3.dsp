import("stdfaust.lib");
import("mi.lib");
import("./utils.lib");

// Hand-tuned parameters

// Receive values from ND voice 2
listeningVoice = 3;

// A mass has at most 3 neighbors in our model
maxDeg = 3;

// ----------------------------
// Nord Drum related Midi logic
// ----------------------------

// Find which Nord Drum voice has the focus.
cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 0, 0, 127, 1);
voice_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedVoice = 1,2,3,4,5,6 :  voice_selector(cc70) :hbargraph("focusedVoice",1,6);

// Our model will listen to incomming CC message only if focus == 1
focus = (listeningVoice == focusedVoice);

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

// -----------------------------------
// Stability conditions for the model:
// -----------------------------------

// Let M_max, the mass with most neighbourghs in the model
// Let n = Card(V(M_max)) with V(x) the Neighbourhood of x
// M_max stable <=> Model Stable <=> Σ Ki + 2ΣZi < 4M
// With Ki in V(M_max) and Zi in V(M_max).
// We suppose all springs have the same K and Z so
// The stability condition for the model is:
// (K < 1/n * (4M - 2*n*Z)) && ( Z < 1/n * (2M - 1/2 * n * K))


mkz_range(mx,kx,zx,n) = equation
with{
    security = 0.2;
    equation = m,k,z
    letrec{
    'm = max(mx, security + n*((1/2)*z + (1/4)*k));
       'k = min(kx, 1/n * (4*m - 2*n*z));
       'z = min(zx, 1/n * (2*m - (1/2)*n*k));
    };
};

// Setting the limits for K and Z
// k, z must be strictly positive!
// 0 < k < 4m
// 0 < z < 2m
// This implies
// 0 < K_max <<<< 4 * M_min
// 0 < Z_max <<<< 2 * M_min
// /!\ It appears that if K_max and Z_max come too close from
// the limit the model crashes

// stiffness
K_preset = 0;
// Damping
Z_preset = 13;
// Mass inertia
M_preset = 10;
// Gain
G_preset = 44;

K_min = 0.0001;
K_max = 1;

Z_min = 0.0001;
Z_max = 0.01;

M_min = 1;
M_max = 10;

// Midi controled sliders for M, K and Z values
mx = hslider("mass[midi:ctrl 31]", M_preset, 0, 127, 1);
m = (mx,focus : holdOrJoin) : ccToVal(M_min, M_max);
kx = hslider("stiffness [midi:ctrl 30]", K_preset, 0, 127, 1);
k = (kx,focus : holdOrJoin) : ccToVal(K_min, K_max);
zx = hslider("damping [midi:ctrl 50]", Z_preset, 0, 127, 1);
z = (zx,focus : holdOrJoin) : ccToVal(Z_min, Z_max);

// Volume and Input force parameters
G_min = 0;
G_max = 0.1;

in_min = 0;
in_max = 10;

gx = hslider("gain [midi:ctrl 19]", G_preset, 0, 127, 1); 
OutGain = (gx,focus : holdOrJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",G_min,G_max);

gateT = nentry("gate[midi:key %listeningVoice]",0,0,127,1):ba.impulsify;
in1 = gateT : ccToVal(in_min,in_max);

model(m_M, m_K, m_Z) = (RoutingLinkToMass: 
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
process = mkz_range(m,k,z,maxDeg), in1: model: *(OutGain) <: co.limiter_1176_R4_stereo;