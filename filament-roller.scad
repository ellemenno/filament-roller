/* filament roller

  - sized to match dimensions of the Creality3 Ender3 roller holder:
    - arm: 30mm OD x 90 mm width
    - bracket: 43mm (1.5mm 40mm 1.5mm) width x 10mm depth x 150mm height
  - fits standard 1kg spool:
    - 54mm ID x 65mm width

  BOM
  - 6806 bearing (30mm bore ID, 42mm OD, 7mm thickness, 6mm sidewall)
  - roller (requires supports under lower internal inset)
  - arm (brim can be helpful)
  - countersunk washer
  - flange nut (for best thread printing, use Wall Ordering: Inside to Outside)
*/

use <threads.scad>
use <lib_filament-roller.scad>

function Bearing6806_OuterDiameter() = 42;
function Bearing6806_InnerDiameter() = 30;
function Bearing6806_Height() = 7;
function Bearing6806_Sidewall() = (Bearing6806_OuterDiameter() - Bearing6806_InnerDiameter()) / 2;
function FilamentSpoolInnerDiameter() = 54;

function RollerOuterDiameter() = FilamentSpoolInnerDiameter(); // outer diameter of roller / inner diameter of spool
function ArmOuterDiameter() = Bearing6806_InnerDiameter(); // outer diameter of arm / inner diameter of bearing
function ArmHeight() = 90; // height/length of arm
function SpacerThickness() = 10 - 1.5;
function SpacerOuterDiameter() = 43 - 1.5*2;

tol = 0.5; // clearance gap between parts
$fn = $preview ? 32 : 128; // number of facets in a 360° arc

module _roller() {
  roller(
    od=FilamentSpoolInnerDiameter(),
    h=ArmHeight(),
    db=Bearing6806_OuterDiameter(),
    hb=Bearing6806_Height(),
    tb=Bearing6806_Sidewall(),
    tolerance=tol
  );
}

module _arm() {
  arm(
    d=Bearing6806_InnerDiameter(),
    h=ArmHeight(),
    spacer_height=SpacerThickness(),
    tolerance=tol
  );
}

module _arm_test() {
  od = Bearing6806_InnerDiameter();
  n = NutThickness(od);
  arm(
    d=od,
    h=n,
    tolerance=tol
  );
}

module _spacer() {
  spacer(
    id=ArmOuterDiameter(),
    od=SpacerOuterDiameter(),
    h=SpacerThickness(),
    tolerance=tol
  );
}

module _washer() {
  id = Bearing6806_InnerDiameter();
  countersunk_washer(
    id=id,
    h=CountersunkWasherThickness(id),
    tolerance=tol
  );
}

module _nut(flange_down=false) {
  tx = flange_down ? [0,0,NutThickness(ArmOuterDiameter())] : [0,0,0];
  rx = flange_down ? [180,0,0] : [0,0,0];
  translate(tx) rotate(rx) {
    flange_nut(
      id=Bearing6806_InnerDiameter(),
      tolerance=tol*1.5
    );
  }
}

module assembly_layout(exploded=true, spacing=10) {
  da = ArmOuterDiameter();
  ha = ArmHeight();
  nt = NutThickness(da);
  st = SpacerThickness();
  kt = CountersunkWasherThickness(da);
  zr = exploded ? nt + kt + ha + da/4 + spacing : nt + st + kt;
  zw = exploded ? -(kt + spacing) : nt + st;
  zs = exploded ? -(st + spacing + kt + spacing) : nt;
  zn = exploded ? -(nt + spacing + st + spacing + kt + spacing) : -tol;
  rotate([70,0,250]) translate([0,0,-(nt+kt)]) {
    translate([0,0,zr]) _roller();
    translate([0,0, 0]) _arm();
    translate([0,0,zw]) _washer();
    translate([0,0,zs]) _spacer();
    translate([0,0,zn]) _nut();
  }
}

module spread_layout(spacing=10) {
  da = ArmOuterDiameter();
  s = HexAcrossCorners(da);
  ss = s + spacing;
  translate([ss/2,s,0]) _roller();
  translate([0,0, 0]) _arm();
  translate([-ss/2,s,0]) _washer();
  translate([-s,0,0]) _spacer();
  translate([ss,0,0]) _nut(flange_down=true);
}

module print_layout(part=0, spacing=10) {
  if (part==1) _roller();
  if (part==2) _arm();
  if (part==3) _washer();
  if (part==4) _spacer();
  if (part==5) _nut(flange_down=true);
  if (part==6) {
    da = ArmOuterDiameter();
    s = HexAcrossCorners(da);
    ss = s/2 + da/2 + spacing;
    _arm_test();
    translate([ss,0,0]) _nut(flange_down=true);
  }
}

module test_layout(spacing=10, cross_section=false) {
  da = ArmOuterDiameter();
  s = HexAcrossCorners(da);
  ss = s/2 + da/2 + spacing;
  nt = NutThickness(da);
  if (cross_section) {
    difference() {
      union() {
        _arm_test();
        _nut(flange_down=false);
      }
      translate([0,0,-nt*0.05]) cube([ss*2, s/2, nt*1.1]); // cross-section
    }
  }
  else {
    union() {
      _arm_test();
      translate([ss,0,0]) _nut(flange_down=true);
    }
  }
}


module main() {
  if (mode=="assembly") assembly_layout(exploded=true);
  if (mode=="print") print_layout(part);
  if (mode=="spread") spread_layout();
  if (mode=="test") test_layout(cross_section=true);
}

mode = "spread"; // ["assembly", "print", "spread", test"]
part = 0; // [1:roller, 2:arm, 3:washer, 4:spacer, 5:nut, 6:test]
main();
