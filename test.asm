# Chương trình: Selection Sort
# hàm list, print, sort, min, swap
#-----------------------------------
# Data segment	
	.data
# Các định nghĩa biến
myArr:		.space 40					# mảng chứa 10 số
buffer:		.space 40					# buffer để đọc file
binf:		.asciiz "D:/DOWNLOADS/Mars4_5/INT10.BIN"	# tên file đọc
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
	la	$a0, binf
	li	$a1, 0			# bật flag để đọc file
	li	$a2, 0
	syscall
	move 	$s6, $v0

	li	$v0, 14			# đọc dữ liệu file vào buffer
	move	$a0, $s6
	la	$a1, buffer
	li	$a2, 40
	syscall

	li	$v0, 16			# đóng file
	syscall
	
# Đưa dữ liệu từ buffer vào mảng
  # Gọi hàm list
  	la	$a0, buffer
  	la	$a1, myArr
	jal	list
	
# In mảng số ban đầu
  # In câu nhắc cho mảng ban đầu
  	li	$v0, 4
  	la	$a0, mang_ban_dau
  	syscall
  # Gọi hàm print
  	la	$a0, myArr
	jal	print

# Sắp xếp mảng bằng thuật toán Selection Sort
# và in ra các bước có thay đổi thứ tự trong dãy
  # In câu nhắc cho phần sắp xếp
  	li	$v0, 4
  	la	$a0, sap_xep
  	syscall
  # Gọi hàm sort
  	la	$a0, myArr
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
  # s0 = addr(buffer[i]), s1 = addr(myArr[i]), s2 = i (= 0)
	move	$s0, $a0		# đổi con trỏ qua s0
	move	$s1, $a1		# đổi con trỏ qua s1
  # for( i = 0; i < 10; i++ )
	li	$s2, 0			# i = 0
loop_l:	beq	$s2, 10, end_list	# kiểm tra (i == 10)
    # đưa từng phần tử vào mảng
	lw	$s3, 0($s0)
	sw	$s3, 0($s1)		# myArr[i] = buffer[i]
  # listloop
	addi	$s0, $s0, 4
	addi	$s1, $s1, 4
	addi	$s2, $s2, 1
	j	loop_l
  # kết thúc list_for
end_list:
	jr	$ra
#-------------------------
# hàm print: in mảng
# In: a0 = addr(myArr[])
# Out: none
# Reserved: none
#-------------------------
print:
  # s0 = arrd(myArr[i]), s1 = i (= 0)
	move	$s0, $a0		# đổi con trỏ qua s0
	addiu	$sp, $sp, -8		
	sw	$s0, 4($sp)		# lưu s0 vào stack
	li	$v0, 4
	la	$a0, bat_dau_mang	# "[ "
	syscall
  # for ( i = 0; i < 10; i++ )
	li	$s1, 0			# i = 0
	sw	$s1, 0($sp)		# lưu s1 vào stack
loop_p:	beq	$s1, 10, end_print	# kiểm tra (i == 10)
    # in từng phần tử trong mảng (syscall)
	li	$v0, 1			# in số nguyên
	lw	$a0, 0($s0)
	syscall				# in khoảng trắng giữa các phần tử
	li	$v0, 4
	la	$a0, space
	syscall
  # printloop
	addi	$s0, $s0, 4
	addi	$s1, $s1, 1
	j	loop_p
  # kết thúc print_for
end_print:
	li	$v0, 4
	la	$a0, ket_thuc_mang	# " ]"
	syscall
	la	$a0, newLine		# xuống dòng
	syscall
	lw	$s0, 4($sp)		# trả giá trị về cho s0
	lw	$s1, 0($sp)		# trả giá trị về cho s1
	addiu	$sp, $sp, 8
	jr	$ra
#----------------------------------
# hàm min: tìm phần tử nhỏ nhất
# In: a0 = addr(myArr[i]), a1 = i
# Out: v0 = min, v1 = addr(min)
# Reserved: none
#----------------------------------
min:
  # s0 = myArr[i], s2 = addr(myArr[i])
	addiu	$sp, $sp, -12
	sw	$s0, 8($sp)		# lưu s0 vào stack
	sw	$s1, 4($sp)		# lưu s1 vào stack
	lw	$s0, 0($a0)		# lưu myArr[i] vào stack
	move	$s2, $a0
loop_m:	addi	$a0, $a0, 4		# i++
  # for (k = i; k < 9; k++ )
	beq	$a1, 9, end_min
	sw	$s0, 0($sp)		# kiểm tra (k == 9)
	lw	$s1, 0($a0)		# s1 = myArr[j] (j > i)
    # Cập nhật giá trị min
    # nếu tìm được phần tử nhỏ hơn
	slt	$s0, $s1, $s0		# kiểm tra (myArr[j] < myArr[i])
	beqz	$s0, continue_m
    # if(myArr[j] < myArr[i])
	move	$s0, $s1		# s0 = myArr[j]
	move	$s2, $a0		# s2 = addr(myArr[j])
	sw	$s0, 0($sp)		# lưu myArr[i] vào stack
  # minloop
continue_m:
	lw	$s0, 0($sp)		# s0 = myArr[i]
	addi	$a1, $a1, 1
	j	loop_m
  # kết thúc min_for
end_min:
  # v0 = min, v1 = addr(min)
	move	$v0, $s0
	move	$v1, $s2
	lw	$s0, 8($sp)		# trả giá trị về cho s0
	lw	$s1, 4($sp)		# trả giá trị về cho s1
	addiu	$sp, $sp, 12
	jr	$ra
#---------------------------------------------------------------------
# hàm min: đảo vị trí hai phần tử
# In: a0 = addr(myArr[i]), a1 = myArr[i], a2 = addr(min), a3 = min
# Out: none
# Reserved: none
#----------------------------------------------------	
swap:
  # Đảo vị trí myArr[i] <-> min
	sw	$a3, 0($a0)	# lưu giá trị của min vào địa chỉ của myArr[i]
	sw	$a1, 0($a2)	# lưu giá trị của myArr[i] vào địa chỉ của min
	jr	$ra
#----------------------------------------
# hàm sort: sắp xếp theo Selection Sort
# In: a0 = addr(myArr[])
# Out: none
# Reserved: none
#----------------------------------------
sort:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# lưu địa chỉ trả về main vào stack
  # s0 = addr(myArr[i]), s1 = i (=0)
	move	$s0, $a0		# đổi con trỏ qua s0
  # for (i = 0; i < 9; i++ )
	li	$s1, 0			# i = 0
loop_s:	beq	$s1, 9, end_sort	# kiểm tra (i == 9)
  # Tìm phần tử nhỏ nhất trong khoảng từ myArr[i] đến myArr[9]
    # Gọi hàm min
	move	$a0, $s0
	move	$a1, $s1
	jal	min
  # Đảo vị trị myArr[i] với phần tử min nếu myArr[i] != min
	beq	$s0, $v1, continue_s	# kiểm tra (myArr[i] == min)
    # Gọi hàm swap	
	move	$a0, $s0
	lw	$a1, 0($s0)
	move	$a2, $v1
	move	$a3, $v0
	jal	swap
  # In mảng vừa có thay đổi thứ tự
    # Gọi hàm print
    	la	$a0, myArr
	jal	print
  # sort_loop
continue_s:
	addi	$s0, $s0, 4
	addi	$s1, $s1, 1
	j	loop_s
  # kết thúc sort_for
end_sort:
	lw	$ra, 0($sp)		# trả giá trị về cho ra
	addiu	$sp, $sp, 4
	j	end
