// Model Infinite Noisy Bell
// Description: A bell/gong with a lot of static noise and infinite sustain.
// Parameters:
//  - Stiffness -> tone:spectra
//  - Damping -> tone:decay
//  - Internal Damping -> tone:bend
//  - Mass -> tone:pitch

import("stdfaust.lib");
import("mi.lib");
import("./utils.lib");
declare options "[midi:on]";

listeningTrack = 1;

cc70 = nentry("cc70[midi:ctrl 70][hidden:1]", 26, 0, 127, 1);
track_selector(s) = *(s==0),*(s==26),*(s==51),*(s==77),*(s==102),*(s==127) :> _;
focusedTrack = 1,2,3,4,5,6 :  track_selector(cc70) :hbargraph("focusedTrack",1,6);

focus = (listeningTrack == focusedTrack);

//@mesh_K param 0.1
//@mesh_Z param 0.01
//@mesh_M param 1.0

ccToVal(ccMin,ccMax,cc) = cc * ((ccMax - ccMin) / 127) + ccMin;

M_min = 0.01;
M_max = 0.01;
mx = hslider("mass[hidden:1][midi:ctrl 31]", 0, 0, 127, 1);
mesh_M = (mx,focus : holdOrJoin) : ccToVal(M_min, M_max) : hbargraph("Mass",M_min,M_max);

K_min = 0.000001;
K_max = 0.0001;
kx = hslider("stiffness [midi:ctrl 30] [hidden:1]", 0, 0, 127, 1);
mesh_K = (kx,focus : holdOrJoin) : ccToVal(K_min, K_max) : hbargraph("Stiffness",K_min,K_max);

Z_min = 0.0000001;
Z_max = 0.0000009; // infinite sustain
zx = hslider("damping [midi:ctrl 50] [hidden:1]", 0, 0, 127, 1);
mesh_Z = (zx,focus : holdOrJoin)  : ccToVal(Z_min, Z_max) : hbargraph("Damping",Z_min,Z_max);

Zosc_min = 0.0000000999;
Zosc_max = 0.0000001;
zOscx = hslider("IDamp[midi:ctrl 54]", 0, 0, 127, 1);
mesh_Zosc = (zOscx,focus : holdOrJoin) : ccToVal(Zosc_min, Zosc_max) : hbargraph("Internal Damping", Zosc_min, Zosc_max);

G_min = 0;
G_max = 0.00001;
gx = hslider("gain [midi:ctrl 19]", 127, 0, 127, 1); 
OutGain = (gx,focus : holdOrJoin) : ccToVal(G_min, G_max) : hbargraph("Out Gain",G_min,G_max);

// Input force value.
gateT = nentry("gate[midi:key %listeningTrack] [hidden:1]",0,0,127,1):ba.impulsify; // ND midi note 60
in_min = 0;
in_max = 100;
in1 = gateT : ccToVal(in_min,in_max);


model = (RoutingLinkToMass: 
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.),
osc(mesh_M, 0, mesh_Zosc,0., 0.) :
RoutingMassToLink : 
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),
spring(mesh_K,mesh_Z, 0., 0.),         par(i, 1,_)
)~par(i, 80, _):         par(i, 80,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2,l4_f1,l4_f2,l5_f1,l5_f2,l6_f1,l6_f2,l7_f1,l7_f2,l8_f1,l8_f2,l9_f1,l9_f2,l10_f1,l10_f2,l11_f1,l11_f2,l12_f1,l12_f2,l13_f1,l13_f2,l14_f1,l14_f2,l15_f1,l15_f2,l16_f1,l16_f2,l17_f1,l17_f2,l18_f1,l18_f2,l19_f1,l19_f2,l20_f1,l20_f2,l21_f1,l21_f2,l22_f1,l22_f2,l23_f1,l23_f2,l24_f1,l24_f2,l25_f1,l25_f2,l26_f1,l26_f2,l27_f1,l27_f2,l28_f1,l28_f2,l29_f1,l29_f2,l30_f1,l30_f2,l31_f1,l31_f2,l32_f1,l32_f2,l33_f1,l33_f2,l34_f1,l34_f2,l35_f1,l35_f2,l36_f1,l36_f2,l37_f1,l37_f2,l38_f1,l38_f2,l39_f1,l39_f2, f_in1) = l0_f1+l20_f1, f_in1+l0_f2+l1_f1+l21_f1, l1_f2+l2_f1+l22_f1, l2_f2+l3_f1+l23_f1, l3_f2+l24_f1, l4_f1+l20_f2+l25_f1, l4_f2+l5_f1+l21_f2+l26_f1, l5_f2+l6_f1+l22_f2+l27_f1, l6_f2+l7_f1+l23_f2+l28_f1, l7_f2+l24_f2+l29_f1, l8_f1+l25_f2+l30_f1, l8_f2+l9_f1+l26_f2+l31_f1, l9_f2+l10_f1+l27_f2+l32_f1, l10_f2+l11_f1+l28_f2+l33_f1, l11_f2+l29_f2+l34_f1, l12_f1+l30_f2+l35_f1, l12_f2+l13_f1+l31_f2+l36_f1, l13_f2+l14_f1+l32_f2+l37_f1, l14_f2+l15_f1+l33_f2+l38_f1, l15_f2+l34_f2+l39_f1, l16_f1+l35_f2, l16_f2+l17_f1+l36_f2, l17_f2+l18_f1+l37_f2, l18_f2+l19_f1+l38_f2, l19_f2+l39_f2;
RoutingMassToLink(m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,m21,m22,m23,m24) = m0, m1, m1, m2, m2, m3, m3, m4, m5, m6, m6, m7, m7, m8, m8, m9, m10, m11, m11, m12, m12, m13, m13, m14, m15, m16, m16, m17, m17, m18, m18, m19, m20, m21, m21, m22, m22, m23, m23, m24, m0, m5, m1, m6, m2, m7, m3, m8, m4, m9, m5, m10, m6, m11, m7, m12, m8, m13, m9, m14, m10, m15, m11, m16, m12, m17, m13, m18, m14, m19, m15, m20, m16, m21, m17, m22, m18, m23, m19, m24,m22;
};
process = in1: model: *(OutGain) : fi.highpass(1, 120) <: co.limiter_1176_R4_stereo;