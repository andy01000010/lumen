$led_count = 180;
$leds_to_render = 13;
$led_strip_width = 9.85;
$led_length = 16.567;
$tray_height = 5.0;
$slab_height = 2.0;
$led_height = 3.5;
$led_wall = 1.5;
$cable_floor =2;

$render_slab = false;
$render_tray = false;
$render_split = false;
$render_mount = true;



//constants
pi = 3.14159265358;
two_pi = pi*2;


// LED strip
angle_per_led = 360/$led_count;
segment_to_length = (1/$led_count)*two_pi;
led_inner_circumference = $led_count * $led_length;
led_inner_radius = led_inner_circumference / two_pi;
led_outer_radius = led_inner_radius + $led_strip_width;

// widths relative to inner LED 

module segment(radius_offset, width, depth){
    radius = led_inner_radius + radius_offset;
    inner = (radius * segment_to_length)/2;
    outer = ((radius+width) * segment_to_length)/2;
    
    linear_extrude(height=depth, center=false) {
        polygon([[-inner,radius_offset], [inner,radius_offset], [outer,radius_offset+width], [-outer,radius_offset+width]]);
    };
}

module cable(radius_offset, width, depth, cable_dia){
    c = 0.1;
    radius = led_inner_radius + (radius_offset/2);
    length = 2*radius * segment_to_length;
    cable_r = cable_dia/2;
       
    difference(){
        segment(radius_offset, width, depth);
        
        hull(){
          translate([0, radius_offset+width/2, $tray_height-(cable_dia*0.7)])
            rotate([0,90,0])
              cylinder(h=length, r1=cable_r, r2=cable_r, center=true);
        
          translate([0, radius_offset+width/2, 2*$tray_height])
            rotate([0,90,0])
              cylinder(h=length, r1=cable_r, r2=cable_r, center=true);
        }
    }
}

module make_slab(inner_offset, outer_offset, h){
    
    inner_edge_radius = led_inner_radius + inner_offset;
    outer_edge_radius =  led_inner_radius + outer_offset;
    
    depth = outer_offset-inner_offset;
    
    inner_w = (inner_edge_radius * segment_to_length)/2;
    outer_w = (outer_edge_radius * segment_to_length)/2;
    
    centre_y = ($led_strip_width/2);
    centre_x = 0;
   
    
    color("yellow")
    linear_extrude(height=h, center=false){
            polygon([
              [-inner_w, inner_offset], 
              [ inner_w, inner_offset], 
              [ outer_w, outer_offset],
              [-outer_w, outer_offset]]);
      };
}

module make_splitter()
{
    slab_h = 5;
    drop = 1.8;
    divide_h = slab_h + drop;

    inner_w = (led_inner_radius * segment_to_length)/2;
    outer_w = (led_outer_radius * segment_to_length)/2;
    inner_wall_width = 1;
    
    light_splitter_offset = 0.00;
    splitter_depth = $led_strip_width - light_splitter_offset;


    // Inner slab and shamfer
    difference(){
        make_slab(-8.5, light_splitter_offset, slab_h);
        
        rotate([40,0,0])
        linear_extrude(height=slab_h*2, center=false)
        polygon([
            [-inner_w, 0],
            [ inner_w-inner_wall_width, 0],
            [ inner_w-inner_wall_width, $led_strip_width],
            [-inner_w, $led_strip_width]
        ]);
    }


    // outer slab and shamfer
    difference(){
        make_slab(splitter_depth, $led_strip_width + 8.5, slab_h);
    
        translate([0,$led_strip_width,0])
        mirror([0,1,1])
        rotate([130,0,0])
        linear_extrude(height=slab_h*2, center=false)
        polygon([
            [-outer_w-0.1, 0],
            [ outer_w-inner_wall_width, 0],
            [ outer_w-inner_wall_width, $led_strip_width],
            [-outer_w, $led_strip_width]
        ]);
    }
  
    /*
    color("black")
    translate([0,0,slab_h-divide_h])
    linear_extrude(height=divide_h, center=false)
        polygon([
            [-inner_w, light_splitter_offset],
            [-inner_w+inner_wall_width, light_splitter_offset],
            [-outer_w+inner_wall_width, splitter_depth],
            [-outer_w, splitter_depth]
        ]);
    */
    
    color("magenta")
    difference()
    {
        translate([0,0,slab_h-divide_h])    
        linear_extrude(height=divide_h, center=false)
            polygon([
                [inner_w, light_splitter_offset],
                [inner_w-inner_wall_width, light_splitter_offset],
                [outer_w-inner_wall_width, splitter_depth],
                [outer_w, splitter_depth]
            ]);

        // Notch of inner edge of drop
        translate([inner_w-.5,0,-drop])
            rotate([0,-90,0])
                linear_extrude(height=drop, center=true)
                    polygon([
                    [0, light_splitter_offset],
                    [drop, light_splitter_offset],
                    [0, light_splitter_offset+1]
                ]);
        
        // Notch of outer edge of drop
        translate([inner_w,$led_strip_width,-drop])
            rotate([0,-90,180])
                linear_extrude(height=drop, center=true)
                    polygon([
                    [0, light_splitter_offset],
                    [drop, light_splitter_offset],
                    [0, light_splitter_offset+1]
                ]);
    }         
    
    
}

module make_segment(){
    color("red")
        segment(0, $led_strip_width, $tray_height-$led_height) ;
    
    color("blue"){
        cable(-8.5, 4.0, $tray_height, 2);
        cable(-5.0, 5.0, $tray_height, 3);
        cable($led_strip_width, 5.0, $tray_height, 3);
        cable($led_strip_width+4.5, 4.0, $tray_height, 2);
    }
    
}


module debug(){
    echo("LED count", $led_count);
    echo("LED length", $led_length);
    echo("LED inner C", led_inner_circumference);
    echo("LED inner R", led_inner_radius);

    echo("Angle/LED", angle_per_led);
    echo("Segment to Led", segment_to_length);
    
}

debug();






for(i=[0:$leds_to_render-1]){
    angle1 =  i * angle_per_led;
    
    x1 = led_inner_radius * cos(angle1);
    y1 = led_inner_radius * sin(angle1);
    
    if($render_tray){
        translate([x1,y1,0]){
            rotate([0,0,270+angle1]){
                make_segment();
            }
        }
    }

    // core strip   
   if($render_slab){ 
       color("red")
       translate([x1,y1,-8]){
           rotate([0,0,270+angle1]){
                difference(){
                    make_slab(-8.5, $led_strip_width + 8.5, $slab_height);
                }
           }
       }
    }
    
    if($render_mount){
      translate([x1,y1,-8]){
        rotate([0,0,270+angle1]){
          make_slab($led_strip_width+8.5, $led_strip_width+8.5+6, 2);
          make_slab($led_strip_width+8.5, $led_strip_width+8.5+3, 10);
            
          make_slab(-11.5, -8.5,  10);
          make_slab(-14.5, -8.5,  2);
        }
      }
    }
    
    // beam splitter
    if($render_split){
        translate([x1,y1,5]){
            rotate([0,0,270+angle1]){
                make_splitter();
            }
        }
    }
}    










