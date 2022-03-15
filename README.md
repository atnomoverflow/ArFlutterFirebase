# ArCore Flutter Firebase

This app will enable you to get a a genrated 3d model from the picture you take and then display it on your screen .

# Brif explanition of the project :

1. User takes a picture.

![App Screenshot](https://drive.google.com/uc?export=view&id=1wT0jnf4W2zf7zB8-GY9xFPGq4Terc8Db)

2. The picture will be saved in firebase store  automatically 

![App Screenshot](https://drive.google.com/uc?export=view&id=1bxernXEq8pUCqJ_0R3tOHCj485n_yfeO)

3. A request with url of the picture for generating a 3d model is created in a real time database

![App Screenshot](https://drive.google.com/uc?export=view&id=1yckdcYQfE5Cdg_VampNcLip-zKg-DfYI)

4. A listener on the real time database will detect any new request added to database 

![App Screenshot](https://drive.google.com/uc?export=view&id=1zl9YCglxrLaTO1P5RnWAQj4azn2a9fj0
)

5. Any new request will trigger an event that will feed the url of the taken picture to the  Z-Gan model that will generate a 3d model.

6. The generated model will be returned as a field in the request.  

---
**NOTE**: 
step 5 and 6 are under develpoment you can find them in this [repo]("https://github.com/atnomoverflow/backend_firebase_admin") . 

---

# How to Install and Run the Project
 
---
**NOTE**: 
I am asuming that you have flutter and git installed 

---
## Install
**1. step:**
clone the repository of the frontend
```sh
git clone git@github.com:atnomoverflow/ArFlutterFirebase.git
```
clone the repository of the backend 
```sh
git clone git@github.com:atnomoverflow/backend_firebase_admin.git
```
**2. step:**
install dependencies 
```sh
cd ArFlutterFirebase
flutter pub get
```
**3. step:**
install dependencies 
```sh
flutter pub get
```
---
**NOTE**: 
there is a small modification on one of the packages(ARcore flutter plugin) that we are going to use that need to be manually changed you can find the change needed to be done to the package in this [PR]("https://github.com/giandifra/arcore_flutter_plugin/pull/141")
do the same changes to the cached dependencies in your project you can find the path to the cashed dependencies in the `.flutter-plugins-dependencies` file .

---

## Run

to run the app on your phone all you need to do is 
```sh
flutter run
```
now we need to run the script that will give us the a 3d model when we request it since we cloned the backend_firebase_admin repo we just need 
```sh
cd backend_firebase_admin
python ./firebase.py
```
---
**NOTE**: 
for now the script wont genrate any model it will only return back a model from internet!!!.

---
