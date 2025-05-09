<?php

namespace App\Http\Controllers\Api;

use App\Models\job;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Resources\jobResource;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class JobController extends Controller
{
    /**
     * Display a listing of jobs.
     */
    public function index(Request $request)
    {
        $jobs = job::latest()->paginate(10);
        if ($jobs->count() > 0) {
            return ApiResponse::sendResponse(200, 'Jobs returned successfully', jobResource::collection($jobs));
        } else {
            return ApiResponse::sendResponse(200, 'No jobs found', []);
        }
    }

    /**
     * Store a newly created job.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'salary' => 'required|numeric',
            'location' => 'required|string|max:255',
            'type' => 'sometimes|string|max:255',
            'num_workers' => 'sometimes|integer|min:1',
        ]);

        if ($validator->fails()) {
            return ApiResponse::sendResponse(422, 'Validation Error', $validator->errors());
        }

        $job = new Job();
        $job->title = $request->title;
        $job->description = $request->description;
        $job->salary = $request->salary;
        $job->location = $request->location;
        $job->type = $request->type ?? 'full-time';
        $job->num_workers = $request->num_workers ?? 1;
        $job->users_id = Auth::id();
        $job->status = 'approved'; // Auto-approve jobs
        
        if ($job->save()) {
            return ApiResponse::sendResponse(201, 'Job created successfully', new jobResource($job));
        } else {
            return ApiResponse::sendResponse(500, 'Failed to create job', null);
        }
    }

    /**
     * Update the specified job.
     */
    public function update(Request $request, $job_id)
    {
        $job = Job::find($job_id);
        
        if (!$job) {
            return ApiResponse::sendResponse(404, 'Job not found', null);
        }

        // Ensure user can only update their own jobs
        if ($job->users_id != Auth::id()) {
            return ApiResponse::sendResponse(403, 'Unauthorized action', null);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'salary' => 'sometimes|numeric',
            'location' => 'sometimes|string|max:255',
            'type' => 'sometimes|string|max:255',
            'num_workers' => 'sometimes|integer|min:1',
        ]);

        if ($validator->fails()) {
            return ApiResponse::sendResponse(422, 'Validation Error', $validator->errors());
        }

        if ($request->has('title')) $job->title = $request->title;
        if ($request->has('description')) $job->description = $request->description;
        if ($request->has('salary')) $job->salary = $request->salary;
        if ($request->has('location')) $job->location = $request->location;
        if ($request->has('type')) $job->type = $request->type;
        if ($request->has('num_workers')) $job->num_workers = $request->num_workers;
        
        if ($job->save()) {
            return ApiResponse::sendResponse(200, 'Job updated successfully', new jobResource($job));
        } else {
            return ApiResponse::sendResponse(500, 'Failed to update job', null);
        }
    }

    /**
     * Remove the specified job.
     */
    public function destroy($job_id)
    {
        $job = Job::find($job_id);
        
        if (!$job) {
            return ApiResponse::sendResponse(404, 'Job not found', null);
        }

        // Ensure user can only delete their own jobs
        if ($job->users_id != Auth::id()) {
            return ApiResponse::sendResponse(403, 'Unauthorized action', null);
        }
        
        if ($job->delete()) {
            return ApiResponse::sendResponse(200, 'Job deleted successfully', null);
        } else {
            return ApiResponse::sendResponse(500, 'Failed to delete job', null);
        }
    }

    /**
     * Update the status of a job.
     */
    public function updateStatus(Request $request, $job_id)
    {
        $job = Job::find($job_id);
        
        if (!$job) {
            return ApiResponse::sendResponse(404, 'Job not found', null);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:pending,approved,rejected,completed',
        ]);

        if ($validator->fails()) {
            return ApiResponse::sendResponse(422, 'Validation Error', $validator->errors());
        }

        // For security, only the job owner or an admin should be able to approve jobs
        // This is a simplified check - in a real app, you might have more complex permission logic
        if ($job->users_id != Auth::id()) {
            return ApiResponse::sendResponse(403, 'Unauthorized action', null);
        }
        
        // Update the status
        $job->status = $request->status;
        
        if ($job->save()) {
            return ApiResponse::sendResponse(200, 'Job status updated successfully', new jobResource($job));
        } else {
            return ApiResponse::sendResponse(500, 'Failed to update job status', null);
        }
    }
}
