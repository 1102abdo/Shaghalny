<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use App\Http\Controllers\Controller;
use App\Http\Resources\WorkerResource;
use App\Models\Worker;
use Illuminate\Http\Request;

class WorkerController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(Request $request)
    {
        $worker = Worker::all();
        if ($worker) {
            return ApiResponse::sendResponse(200,'Workers returned Successfully',WorkerResource::collection($worker));
        }else{
            return ApiResponse::sendResponse(200,'No Workers Found',[]);

        }
    }
}
