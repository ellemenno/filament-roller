use <threads.scad> // uses https://github.com/rcolyer/threads-scad, modified to add chamfer on hex nut


function WasherThickness(id) = id/6;
function CountersunkWasherThickness(id) = id/3;

module washer(id, h=0, tolerance=0.4) {
  wt = h > 0 ? h : WasherThickness(id);
  wd = HexAcrossCorners(id);
  tt = tolerance/2;
  difference() {
    cylinder(h=wt, d=wd);
    translate([0,0,-tt]) cylinder(h=wt+tolerance, d=id+tolerance);
  }
}

module washer_countersink(id, h=0, tolerance=0.4) {
  wt = (h > 0) ? h : WasherThickness(id);
  wd = HexAcrossCorners(id);
  h3 = wt/3;
  tt = tolerance/2;
  d1 = id+tolerance;
  d2 = wd-wt+tolerance;
  e = 0.009;
  union() {
    translate([0,0,h3+h3-e]) cylinder(h=h3+tt+e, d=d2);
    translate([0,0,h3]) cylinder(h=h3, d1=d1, d2=d2);
    translate([0,0,-tt+e]) cylinder(h=h3+tt+e, d=d1);
  }
}

module countersunk_washer(id, h=0, tolerance=0.4) {
  difference() {
    washer(id, h, tolerance=tolerance);
    washer_countersink(id, h, tolerance=tolerance);
  }
}

module flange_nut(id, tolerance=0.4) {
  t = WasherThickness(id);
  n = NutThickness(id);
  w = HexAcrossCorners(id);
  union() {
    HexNut(diameter=id, thickness=n, tooth_angle=45, tolerance=tolerance, bottom_chamfer=true);
    translate([0,0,n-t]) difference() {
      washer(id, tolerance=tolerance);
      translate([0,0,-t/4]) cylinder(h=t*2, d=id+t); // bore
    }
  }
}

module roller(od, h, db, hb, tb, tolerance=0.4) {
  tt = tolerance / 2;
  translate([0,0,-tt]) difference() {
    translate([0,0,tt]) cylinder(h=h-tolerance, d=od-tolerance*2);
    cylinder(h=hb, d=db+tolerance); // bottom bearing bore
    cylinder(h=h, d=db-tb/2); // arm bore
    translate([0,0,h-hb+tt]) cylinder(h=hb, d=db+tolerance); // top bearing bore
  }
}

module arm(d, h, spacer_height=0, tolerance=0.4) {
  wh = CountersunkWasherThickness(d);
  nh = NutThickness(d);
  sh = spacer_height;
  ch = d/16; // cap height
  union() {
    translate([0,0,nh]) {
      translate([0,0,sh]) {
        translate([0,0,h+wh]) cylinder(h=ch, d1=d, d2=d-d/4);
        cylinder(h=h+wh, d=d);
        translate([0,0,0]) washer_countersink(id=d, h=wh, tolerance=0);
      }
      cylinder(h=sh, d=d);
    }
    ScrewThread(outer_diam=d, height=nh, tooth_angle=45, tolerance=tolerance);
  }
}

module spacer(id, od, h, tolerance=0.4) {
  tt = tolerance/2;
  difference() {
    cylinder(h=h, d=od-tolerance*2);
    translate([0,0,-tt]) cylinder(h=h+tolerance, d=id+tolerance*2);
  }
}
