<?php

abstract class User {
    public $id;
    public $name;
    public $email;
    protected $password;
    public $role;
    public $ban;
    public $created_at;
    public $updated_at;
    function __construct($id,$name,$email,$password,$role,$ban,$created_at,$updated_at)
    {
        $this->id=$id;
        $this->name=$name;
        $this->email=$email;
        $this->password=$password;
        $this->role=$role;
        $this->ban=$ban;
        $this->created_at=$created_at;
        $this->updated_at=$updated_at;
        
    }
    public static function login($email , $password){
        $user = null;
        $qry = "SELECT * FROM USERS WHERE email = '$email' AND password = '$password' ";
        require_once('config.php');
        $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
        $rslt = mysqli_query($cn,$qry);
        if ($arr = mysqli_fetch_assoc($rslt) ) {
            switch ($arr["role"]) {
                // case 'Workers':
                //    $user = new Workers($arr["id"],$arr["name"],$arr["email"],$arr["password"],$arr["role"],$arr["ban"],$arr["created_at"],$arr["updated_at"]);
                //     break;
                case 'Empolyers':
                   $user = new Employers($arr["id"],$arr["name"],$arr["email"],$arr["password"],$arr["role"],$arr["ban"],$arr["created_at"],$arr["updated_at"]);
                    break;
                
                    case 'admin':
                        $user = new Admin($arr["id"],$arr["name"],$arr["email"],$arr["password"],$arr["role"],$arr["ban"],$arr["created_at"],$arr["updated_at"]);
                         break;
            }
        }
        mysqli_close($cn);
        return $user ;
    }
}

class Admin extends User{
    public $role = "admin";
     function get_users(){
        $qry = "SELECT ID,name,email,role FROM USERS ORDER BY CREATED_AT";
        require_once('config.php');
        $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
        $rslt = mysqli_query($cn,$qry);
        $data = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
        mysqli_close($cn);
        return $data;
     }
     function get_jobs(){
      $qry = "SELECT * FROM jobs join users on jobs.user_id = users.id ORDER BY jobs.CREATED_AT";
      require_once('config.php');
      $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
      $rslt = mysqli_query($cn,$qry);
      $data = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
      mysqli_close($cn);
      return $data;

     }
     function delete_jobs($job_id){
      $qry = "DELETE FROM jobs WHERE id = $job_id";
      require_once('config.php');
      $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
      $rslt = mysqli_query($cn,$qry);
      mysqli_close($cn);
      return $rslt;

     }
     function Ban_users($user_id){
      $qry = "UPDATE users SET ban = 1 WHERE id= $user_id";
      require_once('config.php');
      $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
      $rslt = mysqli_query($cn,$qry);
      mysqli_close($cn);
      return $rslt;

     }
     function delete_account($user_id){
      $qry = "DELETE FROM users WHERE id = $user_id";
      require_once('config.php');
      $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
      $rslt = mysqli_query($cn,$qry);
      mysqli_close($cn);
      return $rslt;

     }

}
class  Employers extends User{
    public static function register($name, $email , $password , $role){
        $qry = "INSERT INTO USERS (name,email,password,role)
        VALUES ('$name','$email','$password','$role')";
        require_once('config.php');
        $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
        $rslt = mysqli_query($cn,$qry);
        mysqli_close($cn);
        return $rslt;
     }


     public function store_job($title,$description,$num_workers,$salary,$type,$location,$picture,$user_id){
        $qry = "INSERT INTO jobs (title,description,num_workers,salary,type,location,picture,user_id)
        values('$title','$description','$num_workers','$salary','$type','$location','$picture',$user_id)";
        require_once("config.php");
        $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
        $rslt = mysqli_query($cn,$qry);
        mysqli_close($cn);
        return $rslt;
     }
}

    //  public function my_posts($user_id){
    //     $qry = "SELECT * FROM posts  WHERE user_id = $user_id ORDER BY CREATED_AT DESC ";
    //     require_once("config.php");
    //     $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
    //     $rslt = mysqli_query($cn,$qry);
    //     $post = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
    //     mysqli_close($cn);
    //     return $post ;
    //  }
    //  public function home_posts(){
    //     $qry = "SELECT * FROM posts join users on posts.user_id=users.id ORDER BY posts.CREATED_AT DESC LIMIT 10  ";
    //     require_once("config.php");
    //     $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
    //     $rslt = mysqli_query($cn,$qry);
    //     $post = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
    //     mysqli_close($cn);
    //     return $post ;
    //  }
    //  public function my_comments($post_id){
    //     $qry = "SELECT * FROM commints join users on commints.user_id = users.id WHERE post_id = $post_id ORDER BY commints.CREATED_AT DESC ";
    //     require_once("config.php");
    //     $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
    //     $rslt = mysqli_query($cn,$qry);
    //     $comment = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
    //     mysqli_close($cn);
    //     return $comment ;
    //  }
   //   public function home_comments(){
   //      $qry = "SELECT * FROM commints join users on commints.user_id = users.id  ORDER BY commints.CREATED_AT DESC ";
   //      require_once("config.php");
   //      $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
   //      $rslt = mysqli_query($cn,$qry);
   //      $comment = mysqli_fetch_all($rslt,MYSQLI_ASSOC);
   //      mysqli_close($cn);
   //      return $comment ;
   //   }
    //  public function profile_image($image,$user_id){
    //     $qry = "UPDATE users SET IMAGE_user ='$image' WHERE id = $user_id";
    //     require_once("config.php");
    //     $cn = mysqli_connect(DB_HOST,DB_USER_NAME,DB_USER_PASSWORD,DB_NAME);
    //     $rslt = mysqli_query($cn,$qry);
    //     mysqli_close($cn);
    //     return $rslt;
    //  }

// }
