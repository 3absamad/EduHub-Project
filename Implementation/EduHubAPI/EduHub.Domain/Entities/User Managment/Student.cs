using EduHub.Domain.Entities.Assessments;
using EduHub.Domain.Entities.Transactions;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.User_Managment
{
    public class Student : User
    {
        public int StudentId { get; set; }
        public string EducationLevel { get; set; } = string.Empty;
        public DateOnly DateOfBirth { get; set; }

        public User User { get; set; } = null!;
        public ICollection<Enrollment> Enrollments { get; set; } = new List<Enrollment>();
        public ICollection<QuizAttempt> QuizAttempts { get; set; } = new List<QuizAttempt>();
        public ICollection<Review> Reviews { get; set; }= new List<Review>();

    }
}
