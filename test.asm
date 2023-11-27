# Chương trình: Selection Sort
# hàm list, print, sort, min, swap
#-----------------------------------
# Data segment	
	.data
# Các định nghĩa biến
myArr:		.space 40			#40 bytes	# mảng chứa 10 số
buffer:		.space 40					# buffer để đọc file
binf:		.asciiz "D:\\Documents\\BTL_LAB_KTMT\\BTL_official\\group\\INT10.BIN"	                              # tên file đọc
space:		.asciiz " "
newLine:	.asciiz "\n"
# Các câu nhắc in ra màn hình
mang_ban_dau:	.asciiz "Mang 10 so nguyen doc tu file:\n"
ket_thuc_mang:	.asciiz "]"
sap_xep:	.asciiz "Sap xep:\n"
bat_dau_mang:	.asciiz "[ "
#------------------------------------------------------
# Code segment
	.text
#------------------------------
# Chương trình chính
#------------------------------
main:
# Đọc file (syscall)
	li	$v0, 13			# mở file
	la	$a0, binf		#a0 chứa tên file
	li	$a1, 0			# bật flag để đọc file 
	li	$a2, 0			# dont care, put 0
	syscall				#after syscall, v0 store the discriptor of file
	move 	$s6, $v0
		
	li	$v0, 14			# đọc dữ liệu file vào buffer
	move	$a0, $s6		# a0 : discriptor of file
	la	$a1, buffer		# a1: address of buffer	
	li	$a2, 40		# a2: numBytes we read
	syscall				


	li	$v0, 16			# đóng file
	syscall
	
				
# Đưa dữ liệu từ buffer vào mảng
  # Gọi hàm list
  	la	$a0, buffer	#address of buffer
  	la	$a1, myArr	#address of array
	jal	list		#
	

# In mảng số ban đầu
  # In câu nhắc cho mảng ban đầu
  	li	$v0, 4
  	la	$a0, mang_ban_dau
  	syscall
  # Gọi hàm print
  	la	$a1, myArr
	jal	print

# Sắp xếp mảng bằng thuật toán Selection Sort
# và in ra các bước có thay đổi thứ tự trong dãy
  # In câu nhắc cho phần sắp xếp
  	li	$v0, 4
  	la	$a0, sap_xep
  	syscall
  # Gọi hàm sort
  	la	$a1, myArr
	jal	sort

# Kết thúc chương trình	(syscall)
end:	li	$v0, 10
	syscall
#--------------------------------------------
# hàm list: đưa số vào mảng
# In: a0 = addr(buffer), a1 = addr(myArr[])
# Out: none
# Reserved: none
#--------------------------------------------
list:
  # t0 = addr(buffer[i]), t1 = addr(myArr[i]), t2 = i (= 0)
	move	$t0, $a0		# đổi con trỏ qua t0
	move	$t1, $a1		# đổi con trỏ qua t1
  # for( i = 0; i < 10; i++ )
	li	$t2, 0			# i = 0
loop_l:	beq	$t2, 10, end_list	# kiểm tra (i == 10)
    # đưa từng phần tử vào mảng
	lw	$t3, 0($t0)
	sw	$t3, 0($t1)		# myArr[i] = buffer[i]
  # listloop
	addi	$t0, $t0, 4
	addi	$t1, $t1, 4
	addi	$t2, $t2, 1
	j	loop_l

  # kết thúc list_for
end_list:
	li	$a0, 1
	li	$a1, 2
	jr	$ra
#-------------------------
# hàm print: in mảng
# In: a1 = addr(myArr[])
# Out: none
# Reserved: none
#-------------------------
print:
  # t1 = arrd(myArr[i]), t2 = i (= 0)
	move	$t1, $a1		# đổi con trỏ qua t1
	li	$v0, 4
	la	$a0, bat_dau_mang	# "[ "
	syscall
  # for ( i = 0; i < 10; i++ )
	li	$t2, 0			# i = 0
loop_p:	beq	$t2, 10, end_print	# kiểm tra (i == 10)
    # in từng phần tử trong mảng (syscall)
	li	$v0, 1			# in số nguyên
	lw	$a0, 0($t1)
	syscall				# in khoảng trắng giữa các phần tử
	li	$v0, 4
	la	$a0, space
	syscall
  # printloop
	addi	$t1, $t1, 4
	addi	$t2, $t2, 1
	j	loop_p
  # kết thúc print_for
end_print:
	li	$v0, 4
	la	$a0, ket_thuc_mang	# " ]"
	syscall
	la	$a0, newLine		# xuống dòng
	syscall
	jr	$ra
#----------------------------------
# hàm min: tìm phần tử nhỏ nhất
# In: a0 = addr(myArr[i]), a1 = i
# Out: v0 = min, v1 = addr(min)
# Reserved: none
#----------------------------------
min:
  # t3 = myArr[i], t5 = addr(myArr[i])
	lw	$t3, 0($a0)
	move	$t5, $a0
loop_m:	
	addi	$a0, $a0, 4		# i++
  # for (k = i; k < 9; k++ )
	beq	$a1, 9, end_min		# kiểm tra (k == 9)
	lw	$t4, 0($a0)		# t4 = myArr[j] (j > i)
    # Cập nhật giá trị min
    # nếu tìm được phần tử nhỏ hơn
	slt	$s0, $t4, $t3		# kiểm tra (myArr[j] < myArr[i])
	beqz	$s0, continue_m
    # if(myArr[j] < myArr[i])
	move	$t3, $t4		# t3 = myArr[j]
	move	$t5, $a0		# t5 = addr(myArr[j])
  # minloop
continue_m:
	addi	$a1, $a1, 1
	j	loop_m
  # kết thúc min_for
end_min:
  # v0 = min, v1 = addr(min)
	move	$v0, $t3
	move	$v1, $t5
	jr	$ra
#----------------------------------------------------
# hàm swap: đảo vị trí hai phần tử
# In: a0 = addr(myArr[i]), a1 = addr(min), a2 = min
# Out: none
# Reserved: none
#----------------------------------------------------	
swap:
  # Đảo vị trí myArr[i] <-> min
	lw	$t3, 0($a0)		# t3 = myArr[i]
	sw	$a2, 0($a0)		# myArr[i] = min
	sw	$t3, 0($a1)		# min = t3
end_swap:
	jr	$ra
#----------------------------------------
# hàm sort: sắp xếp theo Selection Sort
# In: a1 = addr(myArr[])
# Out: none
# Reserved: $ra
#----------------------------------------
sort:
	addi	$sp, $sp, -4
	sw 	$ra, 0($sp)
  # t6 = addr(myArr[i]), t7 = i (=0)
	move	$t6, $a1		# đổi con trỏ qua t1
  # for (i = 0; i < 9; i++ )
	li	$t7, 0			# i = 0
	
loop_s:	
	beq	$t7, 9, end_sort	# kiểm tra (i == 9)
  # Tìm phần tử nhỏ nhất trong khoảng từ myArr[i] đến myArr[9]
    # Gọi hàm min
	move	$a0, $t6
	move	$a1, $t7
	jal	min
  # Đảo vị trị myArr[i] với phần tử min nếu myArr[i] != min
	beq	$t6, $v1, continue_s	# kiểm tra (myArr[i] == min)
    # Gọi hàm swap	
	move	$a0, $t6
	move	$a1, $v1
	move	$a2, $v0
	jal	swap
  # In mảng vừa có thay đổi thứ tự
    # Gọi hàm print
    	la	$a1, myArr
	jal	print
  # sort_loop
continue_s:
	addi	$t6, $t6, 4
	addi	$t7, $t7, 1
	j	loop_s
  # kết thúc sort_for
end_sort:
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra
