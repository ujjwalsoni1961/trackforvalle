import { Component, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule, FormGroup, FormBuilder, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDialogModule, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

@Component({
  selector: 'app-edit-user-dialog',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatDialogModule
  ],
  templateUrl: './edit-user-dialog.component.html',
  styleUrl: './edit-user-dialog.component.scss'
})
export class EditUserDialogComponent {
  userForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    private dialogRef: MatDialogRef<EditUserDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {
    const [firstName = '', lastName = ''] = data.fullName ? data.fullName.split(' ') : ['', ''];
    this.userForm = this.fb.group({
      first_name: [firstName, [Validators.required, Validators.minLength(2)]],
      last_name: [lastName, [Validators.required, Validators.minLength(2)]],
      email: [data.email, [Validators.required, Validators.email]],
      phone: [data.phone || '', [Validators.required, Validators.pattern(/^[0-9]{10,15}$/)]]
    });
  }

  onSubmit() {
    if (this.userForm.valid) {
      const { first_name, last_name, email, phone } = this.userForm.value;
      const result = {
        first_name,
        last_name,
        email,
        phone
      };
      this.dialogRef.close(result);
    }
  }

  onCancel() {
    this.dialogRef.close();
  }

  getErrorMessage(controlName: string): string {
    const control = this.userForm.get(controlName);
    if (control?.hasError('required')) {
      return `${controlName === 'first_name' ? 'First Name' : controlName === 'last_name' ? 'Last Name' : controlName === 'email' ? 'Email' : 'Phone Number'} is required`;
    }
    if (control?.hasError('email')) {
      return 'Invalid email format';
    }
    if (control?.hasError('minlength')) {
      return `${controlName === 'first_name' ? 'First Name' : 'Last Name'} must be at least 2 characters`;
    }
    if (control?.hasError('pattern') && controlName === 'phone') {
      return 'Phone number must be 10 digits';
    }
    return '';
  }
}