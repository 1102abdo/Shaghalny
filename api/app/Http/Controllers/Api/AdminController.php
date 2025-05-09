<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Helpers\ApiResponse;

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
            
            // Check if user is an admin (you'll need to add an is_admin column to your users table)
            if (!$user->is_admin) {
                return ApiResponse::sendResponse(403, 'Unauthorized: Admin access required', []);
            }
            
            $data['token'] = $user->createToken('admin-login')->plainTextToken;
            $data['name'] = $user->name;
            $data['email'] = $user->email;
            
            return ApiResponse::sendResponse(200, 'Admin Login Successful', $data);
        } else {
            return ApiResponse::sendResponse(401, 'Invalid Credentials', []);
        }
    }
}