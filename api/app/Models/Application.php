<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Application extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'experience',
        'skills',
        'cv',
        'bin',
        'jobs_id',
        'workers_id',
        'status',
    ];

    // علاقة مع الوظيفة
    public function job()
    {
        return $this->belongsTo(Job::class, 'jobs_id');
    }

    // علاقة مع العامل
    public function worker()
    {
        return $this->belongsTo(Worker::class, 'workers_id');
    }
} 