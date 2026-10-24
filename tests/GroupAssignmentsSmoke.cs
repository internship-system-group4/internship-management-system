using System;
using System.Collections.Generic;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

class GroupAssignmentsSmoke
{
    static void Check(bool passed, string message)
    {
        if (!passed) throw new Exception(message);
    }

    static void Main()
    {
        GroupRepository groups = new GroupRepository();
        UserRepository users = new UserRepository();
        PlacementRepository placements = new PlacementRepository();
        StudentGroup first = new StudentGroup { Name = "Group A", AcademicSupervisorId = "a1" };
        groups.SaveAssignments(first, new List<string> { "s1", "s2" });
        Check(!string.IsNullOrEmpty(first.Id), "Group ID was not assigned");
        Check(groups.GetById(first.Id).StudentIds.Count == 2, "Group members were not stored");
        Check(users.GetStudentsBySupervisor("a1").Count == 2, "Supervisor cannot retrieve assigned students");
        Check(users.GetAcademicSupervisor("a1").GroupIds.Contains(first.Id), "Supervisor group list was not stored");
        Check(placements.GetByAcademicSupervisor("a1").Count == 2, "Placements did not inherit the supervisor");

        StudentGroup duplicate = new StudentGroup { Name = "Duplicate", AcademicSupervisorId = "a2" };
        bool rejected = false;
        try { groups.SaveAssignments(duplicate, new List<string> { "s1" }); }
        catch (InvalidOperationException) { rejected = true; }
        Check(rejected, "Assigned student was accepted into a new group");
        Check(groups.GetAll().Count == 1 && users.GetStudent("s1").GroupId == first.Id,
            "Rejected group creation changed assignments");

        first.AcademicSupervisorId = "a2";
        groups.SaveAssignments(first, new List<string> { "s1", "s2" });
        Check(users.GetStudentsBySupervisor("a1").Count == 0, "Former supervisor still sees students");
        Check(users.GetStudentsBySupervisor("a2").Count == 2, "New supervisor cannot retrieve students");
        Check(placements.GetByAcademicSupervisor("a1").Count == 0, "Former supervisor still sees placements");
        Check(placements.GetByAcademicSupervisor("a2").Count == 2, "New supervisor cannot retrieve placements");
        Check(!users.GetAcademicSupervisor("a1").GroupIds.Contains(first.Id), "Former supervisor still has group");
        Check(users.GetAcademicSupervisor("a2").GroupIds.Contains(first.Id), "New supervisor is missing group");

        groups.SaveAssignments(first, new List<string> { "s1" });
        Check(users.GetStudent("s2").GroupId == null, "Removed student still has a group");
        Check(placements.GetByAcademicSupervisor("a2").Count == 1, "Removed student still appears in placement query");

        StudentGroup second = new StudentGroup { Name = "Group B", AcademicSupervisorId = "a1" };
        groups.SaveAssignments(second, new List<string> { "s2" });
        Check(placements.GetByAcademicSupervisor("a1").Count == 1, "Second group's placement is missing");
        Check(!GroupRepository.IsAvailableForGroup(users.GetStudent("s2"), groups.GetAll(), first.Id),
            "Assigned student is offered to another group");
        Check(GroupRepository.IsAvailableForGroup(users.GetStudent("s2"), groups.GetAll(), second.Id),
            "Existing member is missing while editing its group");
        Check(!GroupRepository.IsAvailableForGroup(new Student { Id = "s2", IsActive = true }, groups.GetAll(), first.Id),
            "Group membership was ignored when the student's GroupId was missing");
        rejected = false;
        try { groups.SaveAssignments(first, new List<string> { "s1", "s2" }); }
        catch (InvalidOperationException) { rejected = true; }
        Check(rejected, "Student was assigned to a second group");
        Check(groups.GetById(second.Id).StudentIds.Contains("s2"), "Rejected save changed the original group");
        Check(users.GetStudent("s2").GroupId == second.Id, "Rejected save changed the student group");
        Check(placements.GetByAcademicSupervisor("a1").Count == 1, "Rejected save changed the placement");

        groups.SaveAssignments(second, new List<string>());
        groups.SaveAssignments(first, new List<string> { "s1", "s2" });
        Check(users.GetStudent("s2").GroupId == first.Id, "Released student could not join another group");
        Check(placements.GetByAcademicSupervisor("a2").Count == 2, "Released student's placement was not reassigned");
        try
        {
            groups.SaveAssignments(new StudentGroup { Name = "Invalid", AcademicSupervisorId = "missing" }, new List<string>());
            throw new Exception("Group was created without a real supervisor");
        }
        catch (InvalidOperationException) { }
        Console.WriteLine("PASS: create, edit, remove, reject duplicate assignment, release and reassign");
    }
}
