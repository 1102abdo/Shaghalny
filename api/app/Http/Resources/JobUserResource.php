<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class JobUserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return[
            'name'        =>        $this->user->name,
            'title'        =>        $this->title,
            'description'       =>        $this->description,
            'num_workers'       =>        $this->num_workers,
            'salary'       =>        $this->salary,
            'location'        =>        $this->location,
            'type'        =>        $this->type,
            'picture'     =>        $this->picture,
        ];
    }
}
