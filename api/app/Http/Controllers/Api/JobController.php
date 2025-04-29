<?php

namespace App\Http\Controllers\Api;

use App\Models\job;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Resources\jobResource;

class JobController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request)
    {
        $jobs = job::latest()->paginate(10);
        if ($jobs) {
            return ApiResponse::sendResponse(200,'jobs returned Successfully',jobResource::collection($jobs));
        }else{
            return ApiResponse::sendResponse(200,'No jobs Found',[]);
        }
    }
}
