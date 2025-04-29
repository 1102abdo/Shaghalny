<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return[
            // 'worker_name'        =>        $this->worker->name , //to get name worker from worke model 
            'name'               =>        $this->name,
            'job_title'          =>        $this->job->title ,
            'email'              =>        $this->email,
            'phone'              =>        $this->phone,
            'experience'         =>        $this->experience,
            'skills'             =>        $this->skills,
            'cv'                 =>        $this->cv,
        ];     }
}
