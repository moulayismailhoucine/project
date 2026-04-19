<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Generic role middleware: checks the authenticated user/patient's role.
 * Usage in routes: middleware('role:admin') or middleware('role:doctor')
 */
class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthenticated.'], 401);
        }

        // Users (admin/doctor) have a 'role' attribute
        if (property_exists($user, 'role') || isset($user->role)) {
            if ($user->role === $role) {
                return $next($request);
            }
        }

        return response()->json([
            'success' => false,
            'message' => "Access denied. Required role: {$role}.",
        ], 403);
    }
}
