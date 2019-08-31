// A triangle mesh with non-linear interraction
// and user controllable K and Z parameters.

import("stdfaust.lib");

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

zk_range(kx,zx,m) = k,z
letrec{
    'k = min(kx, 1/n * (4*m - 2*n*z));
    'z = min(zx, 1/n * (2*m - 1/2*n*k));
};

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

// We redefine some functions from mi.lib
ground(x0) = equation
with{
  // could this term be removed or simlified? Need "unused" input force signal for routing scheme
  C = 0;
  equation = x
    letrec{
        'x = (x : initState(x0)) + *(C);
    };
};

mass(m,x0,x1) = equation
with{
  A = 2;
  B = -1;
  C = 1/m;
  equation = x
    letrec{
    'x = A*(x : initState(x0)) + B*(x' : initState((x1,x0))) + *(C);
    };
};

// We changed the parameters order
// because partial functions expect non-provided parameters
// to be the rightmost ones.
spring(x1r0,x2r0,k,z,x1,x2) =
  k*(x1-x2) +
  z*((x1 - (x1' : initState(x1r0))) - (x2 - (x2' : initState(x2r0)))) <: *(-1),_;

nlPluck(k,scale,x1,x2) =
  select2(
    absdeltapos>scale,
    select2(
      absdeltapos>(scale*0.5),
      k*deltapos,
      k*(ma.signum(deltapos)*scale*0.5 - deltapos)),
    0) <:  *(-1),_
with{
  deltapos = x1 - x2;
  absdeltapos = abs(deltapos);
};

posInput(init) = _,_ : !,_ : initState(init);

initState((init)) = R(0,init)
with{
  R(n,(initn,init)) = +(initn : ba.impulsify@n) : R(n+1,init);
  R(n,initn) = +(initn : ba.impulsify@n);
};

// We added two inputs for K and Z to the model function.
// We pass K,Z through Routinglinktomass into Routingmasstolink
// which in turns plug those values into the relevant springs.
model = 
(
 RoutingLinkToMass : ground(0.), mass(1.,0., 0.), mass(1.,0., 0.),mass(1.,0., 0.),posInput(0.), _, _ :
 RoutingMassToLink : 
 spring(0.05,0.01, 0., 0.), spring(0., 0.), spring(0., 0.),     
 spring(0., 0.),
 nlPluck(nlK,nlScale), par(i, 1,_)
) ~par(i, 10, _) : 
par(i, 10,!), par(i,  1, _)
with{
RoutingLinkToMass(l0_f1,l0_f2,l1_f1,l1_f2,l2_f1,l2_f2,l3_f1,l3_f2,l4_f1,l4_f2, p_in1, k, z) = l0_f1, l0_f2+l1_f1+l3_f2, l1_f2+l2_f1+l4_f2, l2_f2+l3_f1, l4_f1, p_in1, k, z;
RoutingMassToLink(m0,m1,m2,m3,m4,k,z) = m0, m1, k, z, m1, m2, k, z, m2, m3, k, z, m3, m1, m4, m2, m3;
};

// Given User-defined kx and zx values, we let the zk_range function feed the model with K and Z
// values such that stability conditions are met.
process = in1, ((kx,zx,m:zk_range): (hbargraph("k",K_min, K_max), hbargraph("z",Z_min, Z_max))) : model : *(OutGain);