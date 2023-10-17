.data
array: .space 40
new_array: .space 40
msg_1: .asciz "Enter array size (from 1 to 10): \n"
msg_2: .asciz "The program ended incorrectly! Size is incorrect!\n"
msg_3: .asciz "Fill all array separated by Enter: \n"
msg_4: .asciz "\n"
msg_5: .asciz "Answer: all elements without minimum\n"

.text

li a7, 4             # Enter a welcome message
la a0, msg_1
ecall

li a7, 5               # Get array size from user, store value to stack and call 
ecall                    # program (check_array_size)
mv a2, a0
addi sp, sp, -4
sw a2, (sp)
jal check_array_size           # a2 - actual parameter (size)

beqz a0, ERROR_wrong_size       # If size is wrong, call error branch

li a7, 4                        # Enter fill array message
la a0, msg_3
ecall

addi sp, sp, -4                 # Store array size to stack and call  
sw a2, (sp)                      # fill array program
jal fill_array                    # a2 - actual parameter (size)

addi sp, sp, -4                 # Store array size to stack and call
sw a2, (sp)                      # program that find minimum array value
jal find_min_in_array             # a2 - actual parameter (size)
mv a3, a0

addi sp, sp, -4                 # Set in stack array size and count of non-minimum
sw a2, (sp)                      # values and call program that create new array
addi sp, sp, -4
sw a3, (sp)
jal create_array                  # a2, a3 - actual parameters (size, minimum array)

addi sp, sp, -4                 # Call program that print new array
sw a0, (sp)
jal print_new_array               # a0 - actual parameter (size of new array)



j end_program

.text
check_array_size:
	#---
	# Formal parameters:
	# 1) array size
	#---
	
	addi sp, sp, -4           # Remember return adress and get parametrs
	sw  ra, (sp)
	
	addi sp, sp, 4
	lw t1, (sp)
	
	li t0, 1                           # Check incorrect size
	bgt t0, t1, incorrect_array_size
	
	li t0, 10
	bgt t1, t0, incorrect_array_size
	
	j correct_array_size
	
	incorrect_array_size:
	li a0, 0
	j end_checking
	
	correct_array_size:
	li a1, 1
	j end_checking
	
	end_checking:                       # Return program
	addi sp, sp, -4
	lw ra (sp) 
	addi sp sp 4 
	ret
	

.text
fill_array:
	#---
	# Formal parameters:
	# 1) array size
	#---

	addi sp, sp, -4             # Remember return adress and get parametrs
	sw  ra, (sp)
	
	addi sp, sp, 4
	lw t2, (sp)
	
	la t0, array
	mv t1, t2
	
	loop_fill_array:                  # Fill array
	beqz t1, end_loop_fill_array
	li a7, 5
	ecall
	sw a0, (t0)
	addi t0, t0, 4
	addi t1, t1, -1
	j loop_fill_array
	
	end_loop_fill_array:               # End filling
	addi sp, sp, -4
	lw ra (sp)                          # Return program
	addi sp sp 4 
	ret
	
	
.text
find_min_in_array:
	#---
	# Formal parameters:
	# 1) array size
	#---
	
	#t0 - array iterator
	#t1 - current_min
	#t2 - current
	#t3 - array size

	addi sp, sp, -4               # Remember return adress and get parametrs
	sw  ra, (sp)
	
	addi sp, sp, 4
	
	la t0, array
	lw t1, (t0)
	lw t3, (sp)
	
	min_loop:                      # In this loop we find min element
	beqz t3, end_find_min_in_array
	lw t2, (t0)
	bgt t2, t1, NO_find_new_min
	
	mv t1, t2
	
	NO_find_new_min:
	addi t0, t0, 4
	addi t3, t3, -1
	
	j min_loop
	
	end_find_min_in_array:            # End finding
	
	mv a0, t1
	addi sp, sp, -4
	lw ra (sp)                         # Return program
	addi sp sp 4 
	ret
	

.text
create_array:
	#---
	# Formal parameters:
	# 1) array size
	# 2) minimum value
	#---

	#t0 - min
	#t1 - size
	#t2 - array_iterator
	#t3 - new_array_iterator
	#t4 - array_value
	#t5 - (return) new_array_size
	
	addi sp, sp, -4         # Remember return adress and get parametrs
	sw  ra, (sp)
	
	addi sp, sp, 4
	lw t0, (sp)
	addi sp, sp, 4
	lw t1, (sp)
	addi sp, sp, -8
	
	la t2, array
	la t3, new_array
	li t5, 0
	
	create_array_loop:             # In this loop we set values in the new array
	beqz t1, end_create_array_loop     # that don't equal minimum 
	lw t4, (t2)
	beq t4, t0, equals_el_and_min
	
	sw t4, (t3)
	addi t3, t3, 4
	addi t5, t5, 1
	
	equals_el_and_min:           
	
	addi t2, t2, 4
	addi t1, t1, -1
	
	j create_array_loop
	
	end_create_array_loop:          # End loop
	
	mv a0, t5
	lw ra (sp)                        # Return program
	addi sp sp 4 
	ret
	

.text
print_new_array:
	#---
	# Formal parameters:
	# 1) new array size
	#---

	#t0 - na_size
	#t1 - na iterator
	#t2 - na value
	
	addi sp, sp, -4          # Remember return adress and get parametrs
	sw  ra, (sp)
	
	addi sp, sp, 4
	lw t0, (sp)
	addi sp, sp, -4
	
	la t1, new_array
	
	li a7, 4
	la a0, msg_5
	ecall
	
	print_new_array_loop:           # In this loop we print array
	beqz t0, end_print_array_loop
	
	lw t2, (t1)
	li a7, 1
	mv a0, t2
	ecall
	li a7, 4
	la a0, msg_4
	ecall
	
	addi t1, t1, 4
	addi t0, t0, -1
	
	j print_new_array_loop
	
	end_print_array_loop:
	
	lw ra (sp)                  # Return program
	addi sp sp 4 
	ret
	

.text
ERROR_wrong_size:         # If error - wrong array size
li a7, 4
la a0, msg_2
ecall

end_program:               # Branch in this loop we want to end program
