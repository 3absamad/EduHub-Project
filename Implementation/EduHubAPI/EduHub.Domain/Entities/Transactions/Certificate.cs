using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class Certificate
    {
        public int CertificateId { get; set; }
        public int EnrollmentId { get; set; }
        public string CertificateNumber { get; set; } = string.Empty;
        public DateTime IssueDate { get; set; }
        public string CertificateUrl { get; set; } = string.Empty;

        public Enrollment Enrollment { get; set; } = null!;
    }
}
