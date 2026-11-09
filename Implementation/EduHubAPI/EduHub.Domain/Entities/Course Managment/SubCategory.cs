using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.Course_Managment
{
    public class SubCategory
    {
        public int SubCategoryId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int CategoryId { get; set; }

        public Category Category { get; set; } = null!;
        public ICollection<Course> Courses { get; set; } = new List<Course>();
    }
}
