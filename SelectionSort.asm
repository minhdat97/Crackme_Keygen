.data  
fin: .asciiz "input.txt"      # filename for input
fout:   .asciiz "output.txt"      # filename for output
buffer: .space 1024


len: .word 44
n: .word 0
a: .space 1000
bsa: .space 1000
tb4: .asciiz "Mang vua nhap la: "
khoangtrang: .asciiz "  "
str3: .asciiz "Mang sau khi sap xep : "
str5: .asciiz " "
.text
#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 


#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 1024     # hardcoded buffer length
syscall            # read from file


#Khoi tao vong lap
li $t1,0
la $t2, a	#mang a
li $t4, 1 #he so=1
li $t5, -1 #bien temp -1 la trang thai chua luu gi
li $t6, 10 #bien co gia tri =10
li $t7, -1 #khoi tao bien -1


#Vong lap
lb      $t0, buffer($0) #load buffer[i] vao t0
sub     $t0, $t0, 48     #chuyen sang so bang cach -48		



strLen:			#tinh do dai chuoi
lb      $t0, buffer($t1)   #load buffer[i]
addi	$t1,$t1,1
bne     $t0, $zero, strLen
sub 	$t1,$t1,1 #i--

Lap:                    #dat toi do dai chuoi buffer
beq     $t1, $t7, Finish
sub     $t1, $t1, 1	#i--
beq     $t1, $t7, LuuSo #neu doc het chuoi thi Luuso roi Finish
lb      $t0, buffer($t1)   #load buffer[i]
subi	$t0, $t0, 48	 #chuyen sang so bang cach -48
slt 	$t3,$t7,$t0 	#kiem tra buffer[i] co phai la so hay ko, co tra ve 1, sai tra ve 0
beq 	$t3, $0,LuuSo	#neu ko la ky tu so, thi tien hanh luu	
slt 	$t3,$t7,$t5
beq 	$t3, $0,Cong1



Tieptuc:	
mul 	$t0,$t0,$t4	#nguoc lai nhan voi he so
add	$t5,$t5,$t0
mul	$t4,$t4,$t6	#hesox10
j Lap



# doc hoan chinh dc mot phan tu
LuuSo:
beq $t5,$t7, Lap
sw      $t5, ($t2)	#luu mang a (t2)
sw      $t5, n
addi    $t2, $t2,4	#dich con tro t2 trong mang a
addi     $t4,$0,1
addi     $t5,$0,-1
j Lap

Cong1:
addi $t5,$t5,1
j Tieptuc
Finish:

##xuat######################################################

#Xuat tb4
li $v0,4
la $a0, tb4
syscall


#Khoi tao gia tri vong lap xuat
lw $t0, n 
li $t1, 0 # i = 0
la $t2, a	
Lap2:
beq $t0,$t1, inget


#Xuat a[i]
li $v0,1
lw $a0,($t2)
syscall


#Xuat khoang trang
li $v0,4
la $a0, khoangtrang
syscall
addi $t2, $t2,4
addi $t1,$t1,1
j Lap2
inget:		
		lw 	$t3 , n
		move 	$s2, $t3
		sll	$s0, $s2, 2		# $s0 = n*4
		sub	$sp, $sp, $s0
		move 	$s1, $zero
		la  	$t2, a
forget:	
		bge	$s1, $s2, exitget	# if i>=n goto exitget
		sll	$t0, $s1, 2		# $t0 = i*4
		add	$t1, $t0, $sp		# $t1 = $sp + i*4
		lw 	$a0, 0($t2)
		sw	$a0, 0($t1)
		addi	$s1, $s1, 1		# i = i + 1
		addi 	$t2, $t2,4
		j	forget


# Thoat for...get
exitget:	
		move	$a0, $sp		# $a0 =  Dia chi cua mang
		move	$a1, $s2		# $a1 = Kich thuoc cua mang
		jal	isort			# isort(a,n)
						# Sap xep mang bang ngan xep
		la	$a0, str3		# Xuat str3
		li	$v0, 4
		syscall
		move	$s1, $zero		# i = 0
		la	$t3, a
		lw	$s2, n	


# for ... print (Xuat phan tu)
forprint:	
		bge	$s1, $s2, exitprint	# if i>=n go to exitprint
		sll	$t0, $s1, 2		# $t0=i*4
		add	$t1, $sp, $t0		# $t1 = dia chi cua mang a
		lw	$a0, 0($t1)		#
		sw	$a0, ($t3)
		li	$v0, 1			# Xuat gia tri a[i]
		syscall				
		la	$a0, str5
		li	$v0, 4
		syscall
		addi	$t3, $t3, 4
		addi	$s1, $s1, 1		# i = i + 1
		j	forprint


# Thoat for... print
exitprint:	
		add	$sp, $sp, $s0		# Xoa Stack
		jal 	Exit


# Isort(a,n)	a la mang, n la so phan tu
# SelectionSort
#into sort
isort:		
		addi	$sp, $sp, -20		# Luu gia tri tren Stack
		sw	$ra, 0($sp)		# Gia tri tra ve
		sw	$s0, 4($sp)		# Dia chi mang
		sw	$s1, 8($sp)		# Gia tri cua i
		sw	$s2, 12($sp)		# Length array
		sw	$s3, 16($sp)		# Gia tri mini
		move 	$s0, $a0		# $s0 = Dia chi cua mang
		move	$s1, $zero		# i = 0
		subi	$s2, $a1, 1		# $s2 = $a1 - 1 <=> $s2 = length(array) - 1 = n-1

isortfor:	
		bge 	$s1, $s2, isortexit	# if i >= $s2 thi thoat lap for...sort <=> for(i=0;i<n-1;i++)
		move	$a0, $s0		# $a0 = Dia chi cua mang
		move	$a1, $s1		# $a1 = $s1 = i = 0
		move	$a2, $s2		# $a2 = $s2 = length(array) - 1 = n-1
		jal	mini			# Nhay den mini
		move	$s3, $v0		# Tra ve gia tri cua mini
		move	$a0, $s0		# Tra ve Mang
		move	$a1, $s1		# Tra ve i
		move	$a2, $s3		# Tra ve mini
		jal	swap
		addi	$s1, $s1, 1		# i ++
		j	isortfor		# Quay lai for...sort


#Thoat vong lap for...sort		
isortexit:	
		lw	$ra, 0($sp)		# Phuc hoi gia tri tu stack
		lw	$s0, 4($sp)
		lw	$s1, 8($sp)
		lw	$s2, 12($sp)
		lw	$s3, 16($sp)
		addi	$sp, $sp, 20		# Phuc hoi con tro Stack
		jr	$ra			# Tra gia tri


# min cua vong lap i
mini:		
		move	$t0, $a0		# $t0 = $a0 = Dia chi mang
		move	$t1, $a1		# $t1 = min_i = $a1 = i
		move	$t2, $a2		# $t2 = $a2 = length(array) - 1
		sll	$t3, $t1, 2		# $t3 = $t1*4
		add	$t3, $t3, $t0		# $t3 = $t0 + $t1*4		
		lw	$t4, 0($t3)		# $t4 = min =a[i]
		addi	$t5, $t1, 1		# $t5 = i+ 1
minifor:	
		bgt	$t5, $t2, miniend	# if ($t5>$t2) got miniend <=> if(j>n-1) goto miniend <=> for(j=i+1;j<=n-1;j++)
		sll	$t6, $t5, 2		# $t6 = $t5 * 4
		add	$t6, $t6, $t0		# $t6 = $t6 + $t5 * 4		
		lw	$t7, 0($t6)		# $t7 = a[j]
		bge	$t7, $t4, miniifexit	# if (a[j]>=min) goto miniexit
		move	$t1, $t5		# mini = j
		move	$t4, $t7		# min = a[j]
miniifexit:	
		addi	$t5, $t5, 1		# j++
		j	minifor
miniend:	
		move 	$v0, $t1		# return mini
		jr	$ra

swap:		
		sll	$t1, $a1, 2		# i * 4
		add	$t1, $a0, $t1		# a + i * 4
		
		sll	$t2, $a2, 2		# mini * 4
		add	$t2, $a0, $t2		# a + mini * 4

		lw	$t0, 0($t1)		# $t0 = a[i]
		lw	$t3, 0($t2)		# $t3 = a[mini]

		sw	$t3, 0($t1)		# a[i] = a[mini]
		sw	$t0, 0($t2)		# a[mini] = a[i]
		jr	$ra			# Tra gia tri
Exit:
##################################################################
# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file


#ghi file
  ###############################################################
  # Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, fout     # output file name
  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
  ###############################################################
  

  #Khoi tao gia tri vong lap xuat
  lw $t0, n 
  li $t2, 0 # i = 0
  li $t4, 1 #heso
  li $t6, 10 #kq chia
  li $t5, 0
  li $t7, 1 #bien temp
  la $t1, a
  Lap3:
  beq $t0,$t2, closefile


  #Xuat a[i]
  li $t4, 1 #heso
  lw $t3, 0($t1)


  #xu ly chu so
Xuly1:
  mul $t4, $t4, $t6 #he so nhan 10
  div $t5, $t3, $t4 # chia cho he so
  bne $t5,$0,Xuly1
  div $t4, $t4, 10
  
Xuly2:
  div $t5, $t3, $t4
  addi $t5,$t5,48
  move $s0, $t5
  sb  $s0, buffer($0)


# Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  la  $a1, buffer
  li    $a2, 1       # hardcoded buffer length
  syscall            # write to file
  subi $t5,$t5,48
  mul $t7, $t4,$t5
  div $t4, $t4, 10	
  sub $t3,$t3, $t7
  bne $t4,$0,Xuly2


  #Xuat khoang trang

# Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  la $a1, str5
  li   $a2, 1       # hardcoded buffer length
  syscall            # write to file
  addi $t1, $t1, 4
  addi $t2, $t2, 1
  j Lap3


  ###############################################################
  # Close the file 
closefile:
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  li	$v0, 10			# EXIT
  syscall		
  ###############################################################
