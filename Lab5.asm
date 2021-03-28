#Spring20 Lab5 Template File

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.
.macro push(%reg)									#-----push-----
	subi $sp, $sp, 4			#	grows stack to empty space	#-----push-----
	sw %reg, 0($sp)				#	saves %reg into space		#-----push-----
.end_macro 										#-----push-----

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.
.macro pop(%reg)			
	lw %reg 0($sp)				# 	loads word into %reg		#-----pop-----
	addi $sp $sp 4				#	shortens stack to space before	#-----pop-----
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y
.macro getCoordinates(%input %x %y)				#-----getCoordinates-----
	add %x, $0, %input					#-----getCoordinates-----
	add %y, $0, %x						#-----getCoordinates-----
	srl %x, %x, 16						#-----getCoordinates-----
	sll %y, %y, 16						#-----getCoordinates-----
	srl %y, %y, 16						#-----getCoordinates-----
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)
.macro formatCoordinates(%output %x %y)				#-----formatCoordinates-----
	sll %output, %x, 16					#-----formatCoordinates-----
	add %output, %output, %y				#-----formatCoordinates-----
.end_macro 							#-----formatCoordinates-----


.data
originAddress: .word 0xFFFF0000

.text

j done
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#
#   clear_bitmap(color)
#	counter = 0
#	starting address = 0xFFFF0000
#	for i in range(4000):
#		i = color
#*****************************************************
clear_bitmap: nop
	push($ra)										#-----clear_bitmap-----
	push($a0)
	push($t0)
	push($t1)
	lw $t0, originAddress				#	loads starting address		#-----clear_bitmap-----
	add $t1, $zero, $zero									#-----clear_bitmap-----
	clearBMloop:										#-----clear_bitmap-----
		sw $a0, ($t0)									#-----clear_bitmap-----
		addi $t0, $t0, 4								#-----clear_bitmap-----
		addi $t1, $t1, 1								#-----clear_bitmap-----
	blt $t1, 0x4000, clearBMloop								#-----clear_bitmap-----
	pop($t1)
	pop($t0)
	pop($a0)
	pop($ra)										#-----clear_bitmap-----
	jr $ra											#-----clear_bitmap-----
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#  draw_pixel(coord, color)
#	x,y = coord
#	x = x * 128
#	x += y
#	x += 0xFFFF0000
#	x = color
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
draw_pixel: nop
	push($ra)										#-----draw_pixel-----
	push($a0)										#-----draw_pixel-----
	push($t0)										#-----draw_pixel-----
	push($t1)										#-----draw_pixel-----
	push($t3)										#-----draw_pixel-----
	push($t4)										#-----draw_pixel-----
	push($a1)										#-----draw_pixel-----
	getCoordinates($a0, $t0, $t1)								#-----draw_pixel-----
	mulu $t3, $t1, 0x80				#	multiply row but 128		#-----draw_pixel-----
	add $t3, $t3, $t0				#	add column num			#-----draw_pixel-----
	mulu $t3, $t3, 4				#	mult by 4 for word size		#-----draw_pixel-----
	lw $t4, originAddress				#	stores start address		#-----draw_pixel-----
	add $t3, $t3, $t4				#	add start address and offset	#-----draw_pixel-----
	sw $a1, ($t3)					#	changes pixel's color		#-----draw_pixel-----
	pop($a1)										#-----draw_pixel-----
	pop($t4)										#-----draw_pixel-----
	pop($t3)										#-----draw_pixel-----
	pop($t1)										#-----draw_pixel-----
	pop($t0)										#-----draw_pixel-----
	pop($a0)										#-----draw_pixel-----
	pop($ra)										#-----draw_pixel-----
	jr $ra											#-----draw_pixel-----
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   get_pixel(coords):
#	x,y = coords
#	x = x * 128
#	x += y
#	x += 0xFFFF0000
#	getColor(x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	push($ra)										#-----get_pixel-----
	getCoordinates($a0, $t0, $t1)								#-----get_pixel-----
	mulu $t3, $t0, 0x80				#	multiply row but 128		#-----get_pixel-----
	add $t3, $t3, $t1				#	add column num			#-----get_pixel-----
	mulu $t3, $t3, 4				#	mult by 4 for word size		#-----get_pixel-----
	lw $t4, originAddress				#	stores start address		#-----get_pixel-----
	add $t3, $t3, $t4				#	add start address and offset	#-----get_pixel-----
	lw $v0, ($t3)					#	stores pixel's color in $v0	#-----get_pixel-----
	pop($ra)										#-----get_pixel-----
	jr $ra											#-----get_pixel-----

#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*******************************************************************************************************************************************************
draw_solid_circle: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	add $s4, $zero, $a2				#	circleColor = s4
	getCoordinates($a0, $t0, $t1)
	sub $t0, $t0, $a1				#	makes starting point the top left of the square that the circle fits in
	sub $t1, $t1, $a1				#	same as above
	add $s5, $zero, $t1				#	ymin - $s5
	mulu $t3, $t0, 0x80				#	multiply row by 128
	add $t3, $t3, $t1				#	add column num
	lw $t4, originAddress				#	stores start address
	add $t3, $t3, $t4				#	add start address and offset				$t3 is address for starting point
	getCoordinates($a0, $t4, $t5)			#	saves xc and yc to t4 and t5 respectively
	add $s0, $t4, $a1				#	$s0 = xmax
	add $s1, $t5, $a1				#	$s1 = ymax
	add $s2, $0, $a1
	mul $s2, $s2, $s2				#	s2 = r^2
	addi $t1, $t1, -1
	
	j skipOnce
	
	xminLoop:
	add $t0, $t0, 1					#	increments i = xmin
	add $t1, $0, $s5
	j skipOnce
	yminLoop:
	add $t1, $t1, 1					#	increments j = ymin
	
	skipOnce:
		sub $t6, $t0, $t4			#	i - xc
		sub $t7, $t1, $t5			#	j - yc
		mulu $t6, $t6, $t6			#	(i-xc)^2
		mulu $t7, $t7, $t7			#	(j-yc)^2
		add $t6, $t6, $t7			#	<<a>> = (i-xc)^2 + (j-yc)^2
	
	blt $t6, $s2 doIt	# if
	j dontDoIt		# else
	doIt:
		push($a1)
		push($a0)
		formatCoordinates($a0, $t0, $t1)
		add $a1, $0, $s4				#	moves color val to a0 to comply with draw_pixel's parameters
		jal draw_pixel
		pop($a0)
		pop($a1)
		
	dontDoIt:
	
	ble $t1, $s1, yminLoop
	ble $t0, $s0, xminLoop
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
		
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop
	push($ra)
	add $t6, $zero, $a0					#	t6 = coords
	add $t7, $zero, $a2					#	t7 = color
	add $t0, $zero, $zero					#	t0 = x = 0
	add $t1, $zero, $a1					#	t1 = y = radius
	mul $t2, $t1, 2
	addi $t3, $0, 3
	sub $t2, $t3, $t2					#	t2 = d = 3 - (2 * r)
	getCoordinates($a0, $t3, $t4)				#	t3 = xc 	t4 = yc
	add $a0, $zero, $t6					#	a0 = coords
	add $a1, $zero, $t7					#	a1 = color
	add $a2, $zero, $t0					#	a2 = x	
	add $a3, $zero, $t1					#	a3 = y
	jal draw_circle_pixels					#	draw_circle_pixels(xc, yc, x, y)
	circleLoop:
		addi $t0, $t0, 1				#	increments x
		bgtz $t2, circleInner				#	branches to inner IF
		j circleElse					#	jumps to else
		circleInner:
			addi $t1, $t1, -1
			addi $t2, $t2, 10			#	d + 10
			sub $t5, $t0, $t1			#	x - y
			mul $t5, $t5, 4
			add $t2, $t2, $t5			#	t2 = d = d + 4 (x - y) + 10
			j circleDone				#	skips else
		circleElse:
			addi $t2, $t2, 6			#	d + 6
			mul $t5, $t0, 4				#	4 * x
			add $t2, $t2, $t5			#	t2 = d = d + 4x + 6
		circleDone:
		add $a0, $zero, $t6				#	a0 = coords
		add $a1, $zero, $t7				#	a1 = color
		add $a2, $zero, $t0				#	a2 = x	
		add $a3, $zero, $t1				#	a3 = y
		jal draw_circle_pixels				#	draw_circle_pixels(xc, yc, x, y)
	bge $t1, $t0 circleLoop
	pop($ra)
	jr $ra
	
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop
	push($ra)
	push($t0)	# xc
	push($t1)	# yc
	push($t2)	# temp storing modded x coord
	push($t3)	# temp storing modded y coord
	push($t4)	# x
	push($t5)	# y
	add $t4, $zero, $a2				#	moves x in case a registers change
	add $t5, $zero, $a3				#	moves y in case a registers change
	getCoordinates($a0, $t0, $t1)			#	splits the coords
	
	add $t2, $t0, $t4				#	xc + x
	add $t3, $t1, $t5				#	yc + y
	formatCoordinates($a0, $t2, $t3)		#	
	jal draw_pixel					#	draw_pixel(xc+x, yc+y)
	
	sub $t2, $t0, $t4				# 	xc - x
	add $t3, $t1, $t5				#	yc + y
	formatCoordinates($a0, $t2,  $t3)
	jal draw_pixel					#	draw_pixel(xc-x, yc+y)
	
	add $t2, $t0, $t4				#	xy + x
	sub $t3, $t1, $t5				# 	yc - y
	formatCoordinates($a0, $t2,  $t3)
	jal draw_pixel					# 	draw_pixel(xc+x, yc-y)
	
	sub $t2, $t0, $t4				#	xc - x
	sub $t3, $t1, $t5				#	yc -y
	formatCoordinates($a0, $t2,  $t3)
	jal draw_pixel					#	draw_pixel(xc-x, yc-y)
	
	add $t2, $t0, $t5				#	xc + y
	add $t3, $t1, $t4				#	yc + x
	formatCoordinates($a0, $t2, $t3)
	jal draw_pixel					#	draw_pixel(xc+y, yc+x)
	
	sub $t2, $t0, $t5				#	xc - y
	add $t3, $t1, $t4				#	yc + x
	formatCoordinates($a0, $t2, $t3)
	jal draw_pixel					#	draw_pixel(xc-y, yc+x)
	
	add $t2, $t0, $t5				#	xc + y
	sub $t3, $t1, $t4				#	yc - x
	formatCoordinates($a0, $t2, $t3)
	jal draw_pixel					#	draw_pixel(xc+y, yc-x)
	
	sub $t2, $t0, $t5				#	xc - y
	sub $t3, $t1, $t4				#	yc - x
	formatCoordinates($a0, $t2, $t3)
	jal draw_pixel					#	draw_pixel(xc-y, yc-x)
	
	pop($t5)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	pop($ra)
	jr $ra






