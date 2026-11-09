using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Assessments
{
    public class QuestionOption
    {
        public int OptionId { get; set; }
        public int QuestionId { get; set; }
        public string OptionText { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }

        public Question Question { get; set; } = null!;
        public ICollection<StudentAnswer> StudentAnswers { get; set; }= new List<StudentAnswer>();
    }
}
