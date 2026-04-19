<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ContactMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'subject',
        'message',
        'user_id',
        'user_role',
        'is_read',
    ];

    protected $casts = [
        'is_read' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getRoleLabelAttribute(): string
    {
        return match($this->user_role) {
            'admin' => 'Admin',
            'doctor' => 'Doctor',
            'patient' => 'Patient',
            'pharmacy' => 'Pharmacy',
            'lab' => 'Laboratory',
            'nurse' => 'Nurse',
            default => 'User without card',
        };
    }

    public function getRoleColorAttribute(): string
    {
        return match($this->user_role) {
            'admin' => 'danger',
            'doctor' => 'success',
            'patient' => 'primary',
            'pharmacy' => 'warning',
            'lab' => 'info',
            'nurse' => 'secondary',
            default => 'dark',
        };
    }
}
