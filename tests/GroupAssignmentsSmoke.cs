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
        groups.SaveAssignments(first, new List<string> { "s1", "s2" });
        Check(groups.GetById(second.Id).StudentIds.Count == 0, "Transferred student remains in former group");
        Check(users.GetStudent("s2").GroupId == first.Id, "Transferred student has wrong group");
        Check(users.GetStudent("s2").AcademicSupervisorId == "a2", "Transferred student has wrong supervisor");
        Check(placements.GetByAcademicSupervisor("a1").Count == 0, "Former supervisor still sees transferred placement");
        Check(placements.GetByAcademicSupervisor("a2").Count == 2, "New supervisor does not see both placements");
        try
        {
            groups.SaveAssignments(new StudentGroup { Name = "Invalid", AcademicSupervisorId = "missing" }, new List<string>());
            throw new Exception("Group was created without a real supervisor");
        }
        catch (InvalidOperationException) { }
        Console.WriteLine("PASS: create, reassign, remove, transfer, student and placement visibility");
    }
}
