<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Helpers\ApiResponse;
use App\Models\User;

class AdminController extends Controller
{
    public function login(Request $request)
    {
        $validate = Validator::make($request->all(), [
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required'],
        ]);

        if ($validate->fails()) {
            return ApiResponse::sendResponse(422, 'Login Validation Error', $validate->errors());
        }

        // Check if user exists and has admin role
        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $user = Auth::user();
            
            // Check if user has admin role
            if ($user->role !== 'admin') {
                return ApiResponse::sendResponse(403, 'Unauthorized: Admin access required', []);
            }
            
            $data['token'] = $user->createToken('admin-login')->plainTextToken;
            $data['name'] = $user->name;
            $data['email'] = $user->email;
            $data['role'] = $user->role;
            
            return ApiResponse::sendResponse(200, 'Admin Login Successful', $data);
        } else {
            return ApiResponse::sendResponse(401, 'Invalid Credentials', []);
        }
    }

    public function getUsers()
    {
        $users = User::all();
        return ApiResponse::sendResponse(200, 'Users retrieved successfully', $users);
    }

    public function getPosts()
    {
        $posts = \App\Models\Job::with('user')->latest()->get()->map(function($post) {
            return [
                'id' => $post->id,
                'title' => $post->title,
                'description' => $post->description,
                'salary' => $post->salary,
                'location' => $post->location,
                'status' => $post->status,
                'user_name' => $post->user ? $post->user->name : 'Unknown',
                'created_at' => $post->created_at,
                'updated_at' => $post->updated_at,
            ];
        });
        return ApiResponse::sendResponse(200, 'Posts retrieved successfully', $posts);
    }

    public function toggleUserBan($userId)
    {
        $user = User::find($userId);
        
        if (!$user) {
            return ApiResponse::sendResponse(404, 'User not found', null);
        }

        // Toggle the ban status
        $user->ban = $user->ban === '1' ? '0' : '1';
        
        if ($user->save()) {
            return ApiResponse::sendResponse(200, 'User status updated successfully', $user);
        } else {
            return ApiResponse::sendResponse(500, 'Failed to update user status', null);
        }
    }

    public function deleteUser($userId)
    {
        $user = User::find($userId);
        
        if (!$user) {
            return ApiResponse::sendResponse(404, 'User not found', null);
        }

        if ($user->role === 'admin') {
            return ApiResponse::sendResponse(403, 'Cannot delete admin users', null);
        }

        if ($user->delete()) {
            return ApiResponse::sendResponse(200, 'User deleted successfully', null);
        } else {
            return ApiResponse::sendResponse(500, 'Failed to delete user', null);
        }
    }
}