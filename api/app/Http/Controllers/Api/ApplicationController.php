<?php

namespace App\Http\Controllers\Api;

use App\Models\Application;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Resources\ApplicationResource;

class ApplicationController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request,$job_id)
    {
        $application = Application::with(['job:id,title','worker:id,name'])->Where('jobs_id',$job_id)->get();
        if ($application) {
            return ApiResponse::sendResponse(200,'application returned Successfully',ApplicationResource::collection($application));
        }else{
            return ApiResponse::sendResponse(200,'No application Found',[]);
        }
    }
}
