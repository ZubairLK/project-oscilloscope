transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/my_pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/dsp.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/VGA_LCD_Driver.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/screen_buffer.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/VIDEO_PLL.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/I2S_Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/oscilloscope.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/compressor.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/line_buffer.v}
vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/i2s_lcd_config.v}

vlog -vlog01compat -work work +incdir+C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/simulation/modelsim {C:/Users/el12zlk/Desktop/ZLK/Lab_5/LCM_VGA_PartA/LCM_VGA/simulation/modelsim/osc_testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  osc_tb

add wave *
view structure
view signals
run 100 ps
