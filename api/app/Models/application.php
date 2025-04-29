<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Application extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'email', 'phone', 'experience', 'skills', 'CV', 'bin', 'jobs_id', 'workers_id',
    ];

    // علاقة الطلب مع الوظيفة
    public function job()
    {
        return $this->belongsTo(Job::class, 'jobs_id');
    }

    // علاقة الطلب مع العامل
    public function worker()
    {
        return $this->belongsTo(Worker::class, 'workers_id');
    }
}
