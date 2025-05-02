<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request){
            $validate = Validator::make($request->all(),[
            'name' => ['required','string','max:255'],
            'email' => ['required','email','max:255','unique:'.User::class],
            'password' => ['required','confirmed',Rules\Password::defaults()],
            'company' => ['required'],
            ],[],[]
            );
            if ($validate->fails()) {
                return ApiResponse::sendResponse(422,'Register Validation Error' , $validate->messages()->all());
               }

            $user = User::create([
                'name'  =>  $request->name,
                'email'  =>  $request->email,
                'password'  =>  bcrypt($request->password),
                'company'  =>  $request->company,
            ]);

            $data['token'] = $user->createToken('Register')->plainTextToken;
            $data['name'] = $user->name;
            $data['email'] = $user->email;
            $data['company'] = $user->company;
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
           if (Auth::attempt(['email'=>$request->email , 'password'=>$request->password])) {
            $user = Auth::user();
            $data['token'] = $user->createToken('login')->plainTextToken;
            $data['name'] = $user->name;
            $data['email'] = $user->email;
            $data['company'] = $user->company;
            return ApiResponse::sendResponse(200,'Login Successfully' , $data);
           }else{
            return ApiResponse::sendResponse(401,'User Not Exist' , []);

           }

        }


        public function logout(Request $request){

            $request->user()->currentAccessToken()->delete();
            return ApiResponse::sendResponse(200,'Logged out Successfully' , []);

        }


}
