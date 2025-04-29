<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\JobController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\WorkerController;
use App\Http\Controllers\Api\JobUserController;
use App\Http\Controllers\Api\AuthWorkerController;
use App\Http\Controllers\Api\ApplicationController;

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
    Route::get('/jobs',JobController::class);

    // ========================== Application Module
    Route::get('/applications/{job_id}',ApplicationController::class);
});
