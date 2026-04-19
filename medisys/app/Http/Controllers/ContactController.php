<?php

namespace App\Http\Controllers;

use App\Mail\ContactMessage;
use App\Models\ContactMessage as ContactMessageModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Auth;

class ContactController extends Controller
{
    public function show()
    {
        return view('contact');
    }

    public function send(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
        ]);

        // Determine user role if authenticated
        $userRole = null;
        $userId = null;
        
        if (Auth::check()) {
            $user = Auth::user();
            $userId = $user->id;
            $userRole = $user->role;
        }

        // Save to database
        $contactMessage = ContactMessageModel::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'subject' => $validated['subject'],
            'message' => $validated['message'],
            'user_id' => $userId,
            'user_role' => $userRole,
        ]);

        try {
            Mail::to('alexandermail4334@gmail.com')->send(new ContactMessage($validated));
            return back()->with('success', 'Your message has been sent successfully!');
        } catch (\Exception $e) {
            // Still save the message even if email fails
            return back()->with('success', 'Your message has been saved. We will respond soon!')->with('warning', 'Email notification failed but message was recorded.');
        }
    }
}
