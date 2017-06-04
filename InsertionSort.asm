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
li   $v0, 13       				# system call for open file
la   $a0, fin      				# board file name
li   $a1, 0        				# Open for reading
li   $a2, 0
syscall            				# open a file (file descriptor returned in $v0)
move $s6, $v0      				# save the file descriptor 


#read from file
li   $v0, 14       				# system call for read from file
move $a0, $s6      				# file descriptor 
la   $a1, buffer   				# address of buffer to which to read
li   $a2, 1024     				# hardcoded buffer length
syscall            				# read from file


#Khoi tao vong lap
li $t1,0
la $t2, a						#mang a
li $t4, 1						#he so=1
li $t5, -1 						#bien temp -1 la trang thai chua luu gi
li $t6, 10 						#bien co gia tri =10
li $t7, -1 						#khoi tao bien -1


#Vong lap
lb      $t0, buffer($0) 		#load buffer[i] vao t0
sub     $t0, $t0, 48    		#chuyen sang so bang cach -48		


strLen:							#tinh do dai chuoi
lb      $t0, buffer($t1)   		#load buffer[i]
addi	$t1,$t1,1
bne     $t0, $zero, strLen
sub 	$t1,$t1,1 				#i--
Lap:                    		#dat toi do dai chuoi buffer
beq     $t1, $t7, Finish
sub     $t1, $t1, 1				#i--
beq     $t1, $t7, LuuSo 		#neu doc het chuoi thi Luuso roi Finish
lb      $t0, buffer($t1)   		#load buffer[i]
subi	$t0, $t0, 48	 		#chuyen sang so bang cach -48
slt 	$t3,$t7,$t0 			#kiem tra buffer[i] co phai la so hay ko, co tra ve 1, sai tra ve 0

beq 	$t3, $0,LuuSo			#neu ko la ky tu so, thi tien hanh luu	

slt 	$t3,$t7,$t5
beq 	$t3, $0,Cong1

Tieptuc:	
mul 	$t0,$t0,$t4				#nguoc lai nhan voi he so
add	$t5,$t5,$t0
mul	$t4,$t4,$t6					#hesox10
j Lap


# doc hoan chinh dc mot phan tu
LuuSo:
beq $t5,$t7, Lap

sw      $t5, ($t2)				#luu mang a (t2)
sw      $t5, n
addi    $t2, $t2,4				#dich con tro t2 trong mang a
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

li $t1, 0 						# i = 0
la $t2, a	
Lap2:
beq $t0,$t1, Exit


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

Exit:
##################################################################
# Close the file 
li   $v0, 16       				# system call for close file
move $a0, $s6      				# file descriptor to close
syscall            				# close file
################################################################
# InsertionSort
jal Sort
j XuatMang

Sort:
addi $s0, $t0, 0 				# $s0 = n
addi $t8, $0, 1					# $t0 = i = 1
la $a1, a 						# dia chi a[i] ban dau co gia tri la a[1]
addi $a1, $a1, 4
while1:
beq	$t8, $s0, end
lw $t1, ($a1)					# $t1 = value of $a1
addi $t2, $t8, 0				# $t2 = j = i
la	$a2, ($a1)
while2:
blez $t2, cont
la	$a3, ($a2)
addi $a3, $a3, -4
lw	$t4, ($a3)
ble	$t4, $t1, cont
la	$a3, ($a2)
addi $a3, $a3, -4
lw	$t5, ($a3)
sw	$t5, ($a2)
addi $t2, $t2, -1
addi $a2, $a2, -4
j while2
cont:
sw	$t1, ($a2)
addi $t8, $t8, 1
addi $a1, $a1, 4
j while1
end:
jr $ra

# Xuat
XuatMang:
la $a0, str3
addi $v0, $zero, 4
syscall

la	$a1, a
addi $t1, $0, 0

XuatPhanTu:
# kiem tra so lan lap
slt $t2, $t1, $s0
beq $t2, $0, Exitt

# xuat phan tu array[i]
lw $a0, ($a1)
addi $v0, $zero, 1
syscall

# xuat khoang trang
addi $a0, $0, 0x20
addi $v0, $0, 11
syscall

# tang i
addi $t1, $t1, 1
addi $a1, $a1, 4

j XuatPhanTu

Exitt:
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
  li $t2, 0 		# i = 0
  li $t4, 1 		#heso
  li $t6, 10 		#kq chia
  li $t5, 0
  li $t7, 1 		#bien temp
  la $t1, a
  Lap3:




  beq $t0,$t2, closefile
  #Xuat a[i]
  li $t4, 1 		#heso
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
  syscall           # write to file

  addi $t1, $t1, 4
  addi $t2, $t2, 1
  j Lap3


  ###############################################################
  # Close the file 
closefile:
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
li	$v0, 10			 # EXIT
syscall		
  ###############################################################


addi $v0, $0, 10
syscall
