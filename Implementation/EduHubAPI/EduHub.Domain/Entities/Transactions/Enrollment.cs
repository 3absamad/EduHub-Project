using EduHub.Domain.Entities.Course_Managment;
using EduHub.Domain.Entities.User_Managment;
using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class Enrollment
    {
        public int EnrollmentId { get; set; }
        public int StudentId { get; set; }
        public int CourseId { get; set; }
        public DateTime EnrollmentDate { get; set; }
        public decimal ProgressPercentage { get; set; }
        public string Status { get; set; } = string.Empty;

        public Student Student { get; set; } = null!;
        public Course Course { get; set; } = null!;
        public Payment? Payment { get; set; }
        public Certificate? Certificate { get; set; }
    }
}
