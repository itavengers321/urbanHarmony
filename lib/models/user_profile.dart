class UsersProfile {
  late String displayName;
  late String uuid;
  late String address;
  late String mobile;
  late String city;
  late String email;
  late String type;
  late String status;

  UsersProfile({
    required this.displayName,
    required this.uuid,
    required this.address,
    required this.mobile,
    required this.city,
    required this.email,
    required this.type,
    required this.status
  });

  UsersProfile.fromJson(Map<dynamic,dynamic> json)
   : displayName=json['displayName'] as String,
   uuid=json['uuid'] as String,
   address=json['address'] as String,
   mobile=json['mobile'] as String,
   city=json['city'] as String,
   email=json['email'] as String,
   status=json['status'] as String,
   type = json['type'] as String;

   Map<dynamic,dynamic> toJson()=><dynamic,dynamic>{
    'uuid':uuid,
    'displayName':displayName,
    'address':address,
    'mobile':mobile,
    'city':city,
    'email':email,
    'status':status,
    'type':type
   };


   Map<String,dynamic> toMap ()=><String,dynamic>{
    'uuid':uuid,
    'displayName':displayName,
    'address':address,
    'mobile':mobile,
    'city':city,
    'email':email,
    'status':status,
    'type':type
   };
}