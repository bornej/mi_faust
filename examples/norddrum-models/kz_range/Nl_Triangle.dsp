// A triangle mesh with non-linear interraction
// and user controllable K and Z parameters.

import("stdfaust.lib");
import("../utils.lib");
mo = library("./mi_mod.lib");
in1 = vslider("pos",1,-1,1,0.0001) : si.smoo;

OutGain = 50.;

// Stability conditions for the model:
// Let M_max, the mass with most neighbourghs in the model
// Let n = Card(V(M_max)) with V(x) the Neighbourhood of x
// M_max stable <=> Model Stable <=> Σ Ki + 2ΣZi < 4M
// With Ki in V(M_max) and Zi in V(M_max).
// We suppose all springs have the same K and Z so
// The stability condition for the model is:
// (K < 1/n * (4M - 2*n*Z)) && ( Z < 1/n * (2M - 1/2 * n * K))

// We assume a mass in the system has at most 4 neighbors
n = 4;

// We use unitary masses (inertia = 1)
m = 1;

// We set the limits for K and Z
// k, z must be strictly positive!
// 0 < k < 4m
// 0 < z < 2M

K_min = 0.01;
K_max = 4*m;

Z_min = 0.01;
Z_max = 2*m;

// We let the user control K and Z values with two sliders
kx = hslider("stiffness [midi:ctrl 30] [hidden:1]", 0, K_min, K_max, 0.001);
zx = hslider("damping [midi:ctrl 50] [hidden:1]", 0, Z_min, Z_max, 0.001);

// We set the paramters for the nonlinear interaction
nlK = 0.05;
nlScale = 0.01;

// We added two inputs for K and Z to the model function.
// We pass K,Z through Routinglinktomass into Routingmasstolink
// which in turns plug those values into the relevant springs.
model = 
(
 RoutingLinkToMass :
 mo.ground(0.),
 mo.mass(1.,0., 0.),
 mo.mass(1.,0., 0.),
 mo.mass(1.,0., 0.),
 mo.posInput(0.),
 _, _ :
 RoutingMassToLink : 
 mo.spring(0., 0.,0.05,0.01),
 mo.spring(0., 0.),
 mo.spring(0., 0.),     
 mo.spring(0., 0.),
 mo.nlPluck(nlK,nlScale), par(i, 1,_)
) ~par(i, 10, _) : 
par(i, 10,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2,l4_f1,l4_f2, p_in1, k, z) = l0_f1, l0_f2+l1_f1+l3_f2, l1_f2+l2_f1+l4_f2, l2_f2+l3_f1, l4_f1, p_in1, k, z;
RoutingMassToLink(m0,m1,m2,m3,m4,k,z) = m0, m1, k, z, m1, m2, k, z, m2, m3, k, z, m3, m1, m4, m2, m3;
};

// Given User-defined kx and zx values, we let the zk_range function feed the model with K and Z
// values such that stability conditions are met.
process = in1, ((kx,zx,m,n:kz_range): (hbargraph("k",K_min, K_max), hbargraph("z",Z_min, Z_max))) : model : *(OutGain);