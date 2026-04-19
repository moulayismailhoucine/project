<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn() => redirect('/login'));
Route::get('/login', fn() => view('auth.login'));
Route::get('/public-booking', fn() => view('appointments.public-booking'));
Route::get('/lang/{lang}', [App\Http\Controllers\LanguageController::class, 'switch'])->name('lang.switch');

// Staff dashboard routes
Route::get('/dashboard',       fn() => view('dashboard'));
Route::get('/patients',        fn() => view('patients.index'));
Route::get('/doctors',         fn() => view('doctors.index'));
Route::get('/medical-records', fn() => view('medical-records.index'));
Route::get('/ordonnances',     fn() => view('ordonnances.index'));
Route::get('/pharmacies',      fn() => view('pharmacies.index'));
Route::get('/laboratories',    fn() => view('laboratories.index'));
Route::get('/appointments',    fn() => view('appointments.index'));

// Patient-specific
Route::get('/patient-profile',     fn() => view('patient.profile'));

// Doctor viewing patient without logout
Route::get('/doctor-patient-view', fn() => view('doctor.patient-view'));

// Pharmacy portal
Route::get('/pharmacy-dashboard', fn() => view('pharmacy.dashboard'));

// Lab portal
Route::get('/lab-dashboard', fn() => view('lab.dashboard'));

Route::get('/logout', fn() => redirect('/login'));
