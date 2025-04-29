<?php

namespace App\Http\Controllers\Api;

use App\Models\job;
use App\Models\User;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Http\Resources\JobUserResource;
use Illuminate\Database\Eloquent\Collection;

class JobUserController extends Controller
{
    /**
     * Handle the incoming request.
     */

    //  to return the jobe employer
    public function __invoke(Request $request , $users_id)
    {
        $jobs = job::with('user:id,name')->Where('users_id',$users_id)->get();
        if ($jobs) {
            return ApiResponse::sendResponse(200,'jobs returned Successfully',JobUserResource::collection($jobs));
        }else{
            return ApiResponse::sendResponse(200,'No jobs Found',[]);
        }
    }
}
