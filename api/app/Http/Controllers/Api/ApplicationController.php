<?php

namespace App\Http\Controllers\Api;

use App\Models\Application;
use App\Models\Worker;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Resources\ApplicationResource;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class ApplicationController extends Controller
{
    /**
     * Get applications for a job
     */
    public function getJobApplications(Request $request, $job_id)
    {
        $application = Application::with(['job:id,title','worker:id,name'])->where('jobs_id', $job_id)->get();
        if ($application->count() > 0) {
            return ApiResponse::sendResponse(200, 'Applications returned successfully', ApplicationResource::collection($application));
        } else {
            return ApiResponse::sendResponse(200, 'No applications found', []);
        }
    }
    
    /**
     * Get applications by a worker
     */
    public function getWorkerApplications(Request $request, $worker_id)
    {
        // Make sure the authenticated worker can only view their own applications
        if (Auth::guard('worker')->check() && Auth::guard('worker')->id() != $worker_id) {
            return ApiResponse::sendResponse(403, 'Unauthorized action', null);
        }
        
        $applications = Application::with(['job:id,title'])
                                 ->where('workers_id', $worker_id)
                                 ->get();
                                 
        if ($applications->count() > 0) {
            return ApiResponse::sendResponse(200, 'Worker applications returned successfully', ApplicationResource::collection($applications));
        } else {
            return ApiResponse::sendResponse(200, 'No applications found', []);
        }
    }
    
    /**
     * Create a new application
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'required|string|max:20',
            'experience' => 'required|string',
            'skills' => 'required|string',
            'jobs_id' => 'required|exists:jobss,id',
            'workers_id' => 'required|exists:workers,id',
            'cv' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return ApiResponse::sendResponse(422, 'Validation Error', $validator->errors());
        }
        
        // Check if this worker has already applied to this job
        $existingApplication = Application::where('jobs_id', $request->jobs_id)
                                        ->where('workers_id', $request->workers_id)
                                        ->first();
                                        
        if ($existingApplication) {
            return ApiResponse::sendResponse(422, 'You have already applied to this job', null);
        }

        $application = new Application();
        $application->name = $request->name;
        $application->email = $request->email;
        $application->phone = $request->phone;
        $application->experience = $request->experience;
        $application->skills = $request->skills;
        $application->jobs_id = $request->jobs_id;
        $application->workers_id = $request->workers_id;
        
        if ($request->has('cv')) {
            $application->cv = $request->cv;
        }
        
        if ($application->save()) {
            return ApiResponse::sendResponse(201, 'Application created successfully', new ApplicationResource($application));
        } else {
            return ApiResponse::sendResponse(500, 'Failed to create application', null);
        }
    }
    
    /**
     * Update application status
     */
    public function updateStatus(Request $request, $application_id)
    {
        $application = Application::find($application_id);
        
        if (!$application) {
            return ApiResponse::sendResponse(404, 'Application not found', null);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:pending,approved,rejected,completed',
        ]);

        if ($validator->fails()) {
            return ApiResponse::sendResponse(422, 'Validation Error', $validator->errors());
        }
        
        // Update the status
        $application->status = $request->status;
        
        if ($application->save()) {
            return ApiResponse::sendResponse(200, 'Application status updated successfully', new ApplicationResource($application));
        } else {
            return ApiResponse::sendResponse(500, 'Failed to update application status', null);
        }
    }
}
