<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class jobResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return[
            'title'              =>        $this->title,
            'description'        =>        $this->description,
            'num_workers'        =>        $this->num_workers,
            'salary'             =>        $this->salary,
            'type'               =>        $this->type,
            'location'           =>        $this->location,
            'picture'            =>        $this->picture,
        ];    }
}
