<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\WorkerController;
use App\Http\Controllers\Api\JobUserController;
use App\Http\Controllers\Api\AuthWorkerController;
use App\Http\Controllers\Api\ApplicationController;
use App\Http\Controllers\Api\AdminController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// ===================================Auth Module
Route::controller(AuthController::class)->group(function(){
    Route::post('register','register');
    Route::post('login','login');
    Route::post('logout','logout')->middleware('auth:sanctum');
});
Route::controller(AuthWorkerController::class)->prefix('worker')->group(function(){
    Route::post('/register','register');
    Route::post('/login','login');
    Route::post('/logout','logout')->middleware('auth:sanctum');
});

Route::middleware('api')->group(function () {
    // ========================== Users Module
    Route::get('/users/{users_id}',JobUserController::class);

    // ========================== Worker Module
    Route::get('/workers',WorkerController::class);

    // ========================== Job Module
    Route::get('/jobs',[JobController::class, 'index']);
    Route::post('/jobs',[JobController::class, 'store']);
    Route::put('/jobs/{job_id}',[JobController::class, 'update']);
    Route::delete('/jobs/{job_id}',[JobController::class, 'destroy']);
    Route::put('/jobs/{job_id}/status',[JobController::class, 'updateStatus']);

    // ========================== Application Module
    Route::get('/applications/{job_id}',[ApplicationController::class, 'getJobApplications']);
    Route::post('/applications',[ApplicationController::class, 'store']);
    Route::put('/applications/{application_id}/status',[ApplicationController::class, 'updateStatus']);
    Route::get('/worker/{worker_id}/applications',[ApplicationController::class, 'getWorkerApplications']);
});

Route::get('/test', function () {
    return response()->json(['message' => 'API is working!']);
});

Route::get('/db-test', function () {
    try {
        DB::connection()->getPdo();
        return response()->json(['message' => 'Database connection successful!']);
    } catch (\Exception $e) {
        return response()->json(['error' => 'Database connection failed: ' . $e->getMessage()], 500);
    }
});

// Admin routes
Route::controller(AdminController::class)->prefix('admin')->group(function(){
    Route::post('/login', 'login');
    // Add other admin routes as needed, with middleware protection
    Route::middleware('auth:sanctum')->group(function(){
        Route::get('/users', 'getUsers');
        Route::get('/posts', 'getPosts');
        Route::put('/users/{userId}/toggle-ban', 'toggleUserBan');
        Route::delete('/users/{userId}', 'deleteUser');
        Route::delete('/posts/{postId}', 'deletePost');
        // Other admin-only endpoints
    });
});



