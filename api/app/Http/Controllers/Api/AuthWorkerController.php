<?php

namespace App\Http\Controllers\Api;

use App\Models\Worker;
use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthWorkerController extends Controller
{
    public function register(Request $request){
            $validate = Validator::make($request->all(),[
            'name' => ['required','string','max:255'],
            'email' => ['required','email','max:255','unique:'.Worker::class],
            'password' => ['required','confirmed',Rules\Password::defaults()],
            'job' => ['required'],
            ],[],[]
            );
            if ($validate->fails()) {
                return ApiResponse::sendResponse(422,'Register Validation Error' , $validate->messages()->all());
               }
                
            $Worker = Worker::create([
                'name'  =>  $request->name,
                'email'  =>  $request->email,
                'password' => Hash::make($request->password),
                'job'  =>  $request->job,
            ]);

            $data['token'] = $Worker->createToken('Register')->plainTextToken;
            $data['name'] = $Worker->name;
            $data['email'] = $Worker->email;
            $data['job'] = $Worker->job;
            return ApiResponse::sendResponse(201,'created Successfully' , $data);
        }
   
   
        public function login(Request $request){
            $validate = Validator::make($request->all(),[
            'email' => ['required','email','max:255'],
            'password' => ['required'],
            ],[],[]
            );
            if ($validate->fails()) {
                return ApiResponse::sendResponse(422,'Login Validation Error' , $validate->errors());
               }
           if (Auth::guard('worker')->attempt(['email'=>$request->email , 'password'=>$request->password])) {
            $Worker = Auth::guard('worker')->user();
            $data['token'] = $Worker->createToken('login')->plainTextToken;
            $data['name'] = $Worker->name;
            $data['email'] = $Worker->email;
            $data['job'] = $Worker->job;
            return ApiResponse::sendResponse(200,'Login Successfully' , $data);
           }else{
            return ApiResponse::sendResponse(401,'Worker Not Exist' , []);

           }

        }


        public function logout(Request $request){
        
            $request->user()->currentAccessToken()->delete();
            return ApiResponse::sendResponse(200,'Logged out Successfully' , []);

        }
    
          
}
