<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;

class Worker extends Authenticatable
{
    use HasFactory, HasApiTokens;

    protected $fillable = [
        'name', 'email', 'password', 'job', 'ban',
    ];

    protected $hidden = [
        'password',
    ];

    // علاقة العامل مع الطلبات الي قدمها
    public function applications()
    {
        return $this->hasMany(Application::class, 'workers_id');
    }

    // علاقة العامل مع الوظائف المسجل بها (علاقة many to many عبر الجدول الوسيط)
    public function jobs()
    {
        return $this->belongsToMany(Job::class, 'jobs_has_workers', 'workers_id', 'jobs_id');
    }
}
