EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:maxim-ic
LIBS:parts
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "iPhone Dock Connector to Mac Serial cable"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MAX3232 IC1
U 1 1 57387970
P 4800 3050
F 0 "IC1" H 4600 3500 60  0000 C CNN
F 1 "MAX3232" H 4900 2150 60  0000 C CNN
F 2 "" H 4800 3050 60  0000 C CNN
F 3 "" H 4800 3050 60  0000 C CNN
	1    4800 3050
	1    0    0    -1  
$EndComp
$Comp
L Dock_connector Dock~Connector
U 1 1 573882D8
P 6675 1200
F 0 "Dock Connector" V 6225 -50 60  0000 C CNN
F 1 "Dock_connector" H 6525 1450 60  0001 C CNN
F 2 "" H 6625 1200 60  0000 C CNN
F 3 "" H 6625 1200 60  0000 C CNN
	1    6675 1200
	-1   0    0    -1  
$EndComp
$Comp
L MINI_DIN_8P_JACK CN?
U 1 1 5738832B
P 4700 1600
F 0 "CN?" H 4700 1225 60  0001 C CNN
F 1 "MiniDIN 8 Male" H 4700 2000 60  0000 C CNN
F 2 "" H 4700 1600 60  0000 C CNN
F 3 "" H 4700 1600 60  0000 C CNN
	1    4700 1600
	1    0    0    -1  
$EndComp
$Comp
L CP1_Small C1
U 1 1 57388401
P 4100 3250
F 0 "C1" H 4250 3300 50  0000 L CNN
F 1 "0.1µF" H 4200 3200 50  0000 L CNN
F 2 "" H 4100 3250 50  0000 C CNN
F 3 "" H 4100 3250 50  0000 C CNN
	1    4100 3250
	-1   0    0    -1  
$EndComp
$Comp
L CP1_Small C2
U 1 1 5738849F
P 4100 3650
F 0 "C2" H 4250 3700 50  0000 L CNN
F 1 "0.1µF" H 4200 3600 50  0000 L CNN
F 2 "" H 4100 3650 50  0000 C CNN
F 3 "" H 4100 3650 50  0000 C CNN
	1    4100 3650
	-1   0    0    -1  
$EndComp
$Comp
L CP1_Small C3
U 1 1 573884D5
P 5650 2750
F 0 "C3" V 5550 2800 50  0000 L CNN
F 1 "0.1µF" V 5550 2500 50  0000 L CNN
F 2 "" H 5650 2750 50  0000 C CNN
F 3 "" H 5650 2750 50  0000 C CNN
	1    5650 2750
	0    -1   1    0   
$EndComp
$Comp
L CP1_Small C4
U 1 1 573884F6
P 5850 3000
F 0 "C4" H 5650 2950 50  0000 L CNN
F 1 "0.1µF" H 5550 3050 50  0000 L CNN
F 2 "" H 5850 3000 50  0000 C CNN
F 3 "" H 5850 3000 50  0000 C CNN
	1    5850 3000
	-1   0    0    1   
$EndComp
$Comp
L CP1_Small C5
U 1 1 57388519
P 6050 2100
F 0 "C5" H 5800 2050 50  0000 L CNN
F 1 "0.1µF" H 5750 2150 50  0000 L CNN
F 2 "" H 6050 2100 50  0000 C CNN
F 3 "" H 6050 2100 50  0000 C CNN
	1    6050 2100
	1    0    0    1   
$EndComp
Wire Wire Line
	5300 1650 5450 1650
Wire Wire Line
	5300 1500 5450 1500
Wire Wire Line
	5300 2850 5850 2850
Wire Wire Line
	4300 3750 4100 3750
Wire Wire Line
	4100 3550 4300 3550
Wire Wire Line
	4100 3150 4300 3150
Wire Wire Line
	4300 3350 4100 3350
Wire Wire Line
	4300 2750 4300 2400
Wire Wire Line
	4300 2400 6050 2400
Text GLabel 5450 3000 2    60   Input ~ 0
MRX
Wire Wire Line
	5300 3000 5450 3000
Text GLabel 5450 1650 2    60   Input ~ 0
MRX
Text GLabel 5450 3200 2    60   Input ~ 0
MTX
Wire Wire Line
	5450 3200 5300 3200
Text GLabel 5450 1500 2    60   Input ~ 0
MTX
$Comp
L GND #PWR?
U 1 1 5738AC31
P 6275 1725
F 0 "#PWR?" H 6275 1475 50  0001 C CNN
F 1 "GND" H 6275 1575 50  0000 C CNN
F 2 "" H 6275 1725 50  0000 C CNN
F 3 "" H 6275 1725 50  0000 C CNN
	1    6275 1725
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 5738ACA5
P 4150 2950
F 0 "#PWR?" H 4150 2700 50  0001 C CNN
F 1 "GND" H 4150 2800 50  0000 C CNN
F 2 "" H 4150 2950 50  0000 C CNN
F 3 "" H 4150 2950 50  0000 C CNN
	1    4150 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 2950 4150 2950
$Comp
L GND #PWR?
U 1 1 5738AE20
P 5850 3200
F 0 "#PWR?" H 5850 2950 50  0001 C CNN
F 1 "GND" H 5850 3050 50  0000 C CNN
F 2 "" H 5850 3200 50  0000 C CNN
F 3 "" H 5850 3200 50  0000 C CNN
	1    5850 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	5850 3100 5850 3200
Wire Wire Line
	5850 2850 5850 2900
Wire Wire Line
	5750 2750 6525 2750
Wire Wire Line
	5300 2750 5550 2750
Wire Wire Line
	6050 2200 6050 2750
Connection ~ 6050 2750
Connection ~ 6050 2400
Wire Wire Line
	5300 1575 6275 1575
Connection ~ 6050 1575
Wire Wire Line
	6050 1050 6050 2000
Wire Wire Line
	6050 1050 6525 1050
Wire Wire Line
	6275 1575 6275 1725
Wire Wire Line
	5300 3450 6250 3450
Wire Wire Line
	6250 3450 6250 2150
Wire Wire Line
	6250 2150 6525 2150
Wire Wire Line
	5300 3650 6400 3650
Wire Wire Line
	6400 3650 6400 2250
Wire Wire Line
	6400 2250 6525 2250
$EndSCHEMATC
