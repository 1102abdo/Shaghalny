<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ApplicationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'experience' => $this->experience,
            'skills' => $this->skills,
            'cv' => $this->CV,
            'status' => $this->status,
            'bin' => $this->bin,
            'jobs_id' => $this->jobs_id,
            'workers_id' => $this->workers_id,
            'job_title' => $this->whenLoaded('job', function () {
                return $this->job->title;
            }),
            'worker_name' => $this->whenLoaded('worker', function () {
                return $this->worker->name;
            }),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
