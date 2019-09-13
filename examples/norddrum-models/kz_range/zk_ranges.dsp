import("stdfaust.lib");

// Test example for the zk_range function
// We want to let a user set the z and k value for a simple mass-ground
// model.
// We want to make sure that whatever values set by the user, the model
// stay stable.

// Stability conditions for a Mass-ground system:
// K + 2Z < 4M
// 0 < K < 4M
// 0 < Z < 2M 

// In the following example we let the user set
// Kx and Zx value with UI sliders.
// the zk_range function take those values as input
// and outputs K, Z values such that the stability condition
// K + 2Z < 4M
// is verified.

zk_range(kx,zx,m) = k,z
letrec{
    'k = min(kx, 4*m - 2*z);
    'z = min(zx, 2*m - 1/2*k);
};

// We suppose a system with unitary mass
m = 1;

// Setting the limits for k and z
// values must be STRICTLY positive
kmin = 0.01;
kmax = 4*m;

zmin = 0.01;
zmax = 2*m; 

// Two user controlled sliders for k and z values
kx= hslider("k [midi:ctrl 30]",0,kmin,kmax,0.01);
zx= hslider("z [midi:ctrl 50]",0,zmin,zmax,0.01);
// Given kx and zx
// zk_range ensure the output k and z values respect the Stability conditions. 
process= kx, zx , m : zk_range : hbargraph("K",0,kmax), hbargraph("Z",0,zmax);