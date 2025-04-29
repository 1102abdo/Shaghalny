<?php

namespace App\Policies;

use App\Models\User;
use App\Models\create_jobs_has_workers_table;
use Illuminate\Auth\Access\Response;

class CreateJobsHasWorkersTablePolicy
{
    /**
     * Determine whether the user can view any models.
     */
    public function viewAny(User $user): bool
    {
        return false;
    }

    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, create_jobs_has_workers_table $createJobsHasWorkersTable): bool
    {
        return false;
    }

    /**
     * Determine whether the user can create models.
     */
    public function create(User $user): bool
    {
        return false;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, create_jobs_has_workers_table $createJobsHasWorkersTable): bool
    {
        return false;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, create_jobs_has_workers_table $createJobsHasWorkersTable): bool
    {
        return false;
    }

    /**
     * Determine whether the user can restore the model.
     */
    public function restore(User $user, create_jobs_has_workers_table $createJobsHasWorkersTable): bool
    {
        return false;
    }

    /**
     * Determine whether the user can permanently delete the model.
     */
    public function forceDelete(User $user, create_jobs_has_workers_table $createJobsHasWorkersTable): bool
    {
        return false;
    }
}
