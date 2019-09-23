import("stdfaust.lib");
import("mi.lib");


in1 = 0; 	//write a specific force input signal operation here


OutGain = 0.5;

str_M = 1.0;
str_K = 0.1;
str_Z = 0.01;

model = (RoutingLinkToMass: 
ground(0.),
ground(0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.),
mass(str_M, 0., 0.) :
RoutingMassToLink : 
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),
spring(str_K,str_Z, 0., 0.),         par(i, 1,_)
)~par(i, 42, _):         par(i, 42,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2,l4_f1,l4_f2,l5_f1,l5_f2,l6_f1,l6_f2,l7_f1,l7_f2,l8_f1,l8_f2,l9_f1,l9_f2,l10_f1,l10_f2,l11_f1,l11_f2,l12_f1,l12_f2,l13_f1,l13_f2,l14_f1,l14_f2,l15_f1,l15_f2,l16_f1,l16_f2,l17_f1,l17_f2,l18_f1,l18_f2,l19_f1,l19_f2,l20_f1,l20_f2, f_in1) = l0_f1, l20_f2, l0_f2+l1_f1, l1_f2+l2_f1, f_in1+l2_f2+l3_f1, l3_f2+l4_f1, l4_f2+l5_f1, l5_f2+l6_f1, l6_f2+l7_f1, l7_f2+l8_f1, l8_f2+l9_f1, l9_f2+l10_f1, l10_f2+l11_f1, l11_f2+l12_f1, l12_f2+l13_f1, l13_f2+l14_f1, l14_f2+l15_f1, l15_f2+l16_f1, l16_f2+l17_f1, l17_f2+l18_f1, l18_f2+l19_f1, l19_f2+l20_f1;
RoutingMassToLink(m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,m21) = m0, m2, m2, m3, m3, m4, m4, m5, m5, m6, m6, m7, m7, m8, m8, m9, m9, m10, m10, m11, m11, m12, m12, m13, m13, m14, m14, m15, m15, m16, m16, m17, m17, m18, m18, m19, m19, m20, m20, m21, m21, m1,m21;
};
process = in1: model: *(OutGain);