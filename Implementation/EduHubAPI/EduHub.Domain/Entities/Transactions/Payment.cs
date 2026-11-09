using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Transactions
{
    public class Payment
    {
        public int PaymentId { get; set; }
        public int EnrollmentId { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; }
        public string PaymentMethod { get; set; } = string.Empty;
        public string TransactionStatus { get; set; } = string.Empty;

        public Enrollment Enrollment { get; set; } = null!;
    }
}
