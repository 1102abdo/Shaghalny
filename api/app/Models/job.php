<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Job extends Model
{
    use HasFactory;

    protected $table = 'jobss';

    protected $fillable = [
        'title',
        'description',
        'num_workers',
        'salary',
        'type',
        'location',
        'picture',
        'users_id',
    ];

    //  علاقة مع المستخدم (user) اللي نشر الشغل
    public function user()
    {
        return $this->belongsTo(User::class, 'users_id');
    }

    //  علاقة مع الـ applications
    public function applications()
    {
        return $this->hasMany(Application::class, 'jobs_id');
    }

    //  علاقة Many to Many مع الـ workers
    public function workers()
    {
        return $this->belongsToMany(Worker::class, 'jobs_has_workers', 'jobs_id', 'workers_id');
    }
}
